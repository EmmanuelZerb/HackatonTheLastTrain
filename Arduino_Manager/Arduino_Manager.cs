using Godot;
using System;
using System.IO.Ports;
using System.Threading;

public partial class Arduino_Manager : Node
{
	SerialPort serialPort;

	// Variables publiques accessibles depuis GDScript
	public int joyX = 512; // Valeur centrale par défaut
	public int joyY = 512; // Valeur centrale par défaut
	public float gyroX = 0;
	public float gyroY = 0;
	public int zoom = 0;
	public int buttonPress = 0;
	
	private bool connected = false;
	private string messageSerie = "";
	private float debugTimer = 0;
	private string portName = "/dev/cu.usbmodem11201"; // Port modifié pour votre configuration
	
	// Méthodes publiques pour accéder aux données depuis GDScript
	public int GetJoyX() 
	{ 
		return joyX; 
	}
	
	public int GetJoyY() 
	{ 
		return joyY; 
	}
	
	public float GetGyroX() 
	{
		return gyroX;
	}
	
	public float GetGyroY() 
	{
		return gyroY;
	}
	
	public int GetZoom() 
	{ 
		return zoom; 
	}
	
	public int GetButtonPress() 
	{ 
		return buttonPress; 
	}
	
	// Méthode pour vérifier que le manager est disponible
	public bool IsActive() 
	{ 
		GD.Print("Arduino Manager est actif!");
		return true; 
	}
	
	public bool IsConnected()
	{
		return connected;
	}
	
	public override void _Ready()
	{
		GD.Print("Arduino_Manager: Ready!");
		simpleInit(); // Initialisation du port série
	}

	public override void _Process(double delta)
	{
		debugTimer += (float)delta;
		
		// Afficher périodiquement l'état de la connexion
		if (debugTimer > 5.0f)
		{
			debugTimer = 0;
			GD.Print("État Arduino: Connecté = " + connected + 
				", Port = " + (serialPort != null ? portName : "NULL") + 
				", IsOpen = " + (serialPort != null ? serialPort.IsOpen.ToString() : "N/A"));
		}
		
		// Vérifier d'abord si le port est censé être ouvert
		if (serialPort != null && serialPort.IsOpen)
		{
			try
			{
				// Essayer de lire depuis le port série
				messageSerie = serialPort.ReadLine();
				connected = true; // Si la lecture réussit, nous sommes connectés
				
				// Traiter le message reçu
				string[] tableauValeurs = messageSerie.Split(':');
				
				// Vérification de sécurité pour éviter IndexOutOfRangeException
				if (tableauValeurs.Length >= 6) 
				{
					// Convertir les valeurs reçues
					if (Int32.TryParse(tableauValeurs[0], out int newJoyX))
						joyX = newJoyX;
					
					if (Int32.TryParse(tableauValeurs[1], out int newJoyY))
						joyY = newJoyY;
					
					// Gyro est en 3ème et 4ème position
					// Utiliser InvariantCulture pour gérer correctement les points décimaux
					if (float.TryParse(tableauValeurs[3].Replace(',', '.'), 
						System.Globalization.NumberStyles.Float, 
						System.Globalization.CultureInfo.InvariantCulture, 
						out float newGyroX))
						gyroX = newGyroX;
					
					if (float.TryParse(tableauValeurs[2].Replace(',', '.'), 
						System.Globalization.NumberStyles.Float, 
						System.Globalization.CultureInfo.InvariantCulture, 
						out float newGyroY))
						gyroY = newGyroY;
					
					if (Int32.TryParse(tableauValeurs[4], out int newZoom))
						zoom = newZoom;
					
					if (Int32.TryParse(tableauValeurs[5], out int newButtonPress))
						buttonPress = newButtonPress;
				}
			}
			catch (TimeoutException)
			{
				// Timeout de lecture - normal s'il n'y a pas de données
			}
			catch (Exception e)
			{
				// Autre erreur
				GD.PrintErr($"Erreur de lecture: {e.Message}");
				connected = false;
				
				try
				{
					serialPort.Close();
				}
				catch (Exception)
				{
					// Ignorer les erreurs lors de la fermeture
				}
			}
		}
		else if (!connected)
		{
			// Tenter de se reconnecter périodiquement
			if (debugTimer > 3.0f)
			{
				simpleInit();
			}
		}
	}

	void simpleInit()
	{
		try
		{
			// Si serialPort existe et est ouvert, on le ferme d'abord
			if (serialPort != null && serialPort.IsOpen)
			{
				serialPort.Close();
			}

			GD.Print("Tentative de connexion au port " + portName + "...");
			serialPort = new SerialPort(portName, 9600) 
			{
				ReadTimeout = 500,   // Temps d'attente avant qu'une lecture échoue
				WriteTimeout = 500,  // Temps d'attente avant qu'une écriture échoue
				Handshake = Handshake.None,
				DtrEnable = true,    // Active Data Terminal Ready 
				RtsEnable = true     // Active Request to Send
			};
			
			serialPort.Open();
			GD.Print("Port série " + portName + " ouvert avec succès !");
			connected = true;
		}
		catch (Exception e)
		{
			GD.PrintErr($"Erreur d'ouverture du port {portName}: {e.Message}");
			serialPort = null;
			connected = false;
		}
	}

	public override void _ExitTree()
	{
		if (serialPort != null && serialPort.IsOpen)
		{
			try
			{
				GD.Print("Fermeture du port série.");
				serialPort.Close();
			}
			catch (Exception)
			{
				// Ignorer les erreurs lors de la fermeture
			}
		}
	}
}

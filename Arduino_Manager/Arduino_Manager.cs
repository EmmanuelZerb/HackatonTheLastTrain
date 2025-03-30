using Godot;
using System;
using System.IO.Ports;

public partial class Arduino_Manager : Node2D
{
	SerialPort serialPort;
	
	bool firstTime = true;
	
	float globalTimer;
	float startTime;
	float currentTime;
	float timeOut = 100;
	string messageSerie;
	bool connected = false;
	
	//Toutes les variables suivantes sont à définir par vous en fonction des 
	//capteurs que vous voulez utiliser
	
	public int potentiometreUn;
	public int potentiometreDeux;
	public int potentiometreTrois;

	public int boutonUn;
	public int boutonDeux;
	public int boutonTrois;

	public int piezzoUn;
	public int piezzoDeux;
	public int piezzoTrois;
	
	public int ultrasonUn;
	public int ultrasonDeux;
	public int ultrasonTrois;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		simpleInit();							// Initialisation simple qui prend en compte le port COM définit à la main
	}

	public override void _Process(double delta){

		if(serialPort.IsOpen){
			messageSerie = serialPort.ReadLine();

			string[] tableauValeurs = messageSerie.Split(':');
			
			//Attention, si le tableau a moins de valeurs que ce qu'on essaye de lire, il y aura une erreur.
			//On peut obtenir le nombre de valeurs avec la ligne de code suivante :
			
			int tailleTableauValeurs = tableauValeurs.Length;
			
			//On peut utiliser des boucles pour optimiser le code.
			//On peut notamment lire toute les valeurs du tableau avec les lignes suivantes :
			
			foreach (var valeur in tableauValeurs)					//Affichage des valeurs dans la console pour debugger
			{
				//GD.Print($"<{valeur}>");
			}
			ultrasonUn = Int32.Parse(tableauValeurs[0]);
			potentiometreUn = Int32.Parse(tableauValeurs[1]);
			
			currentTime = Time.GetTicksMsec();
			
			if(currentTime - startTime > 30000 && firstTime){
				GD.Print("délais est passé");
				firstTime = false;
				SendCharacter('1');
			}
		}
	}

	void simpleInit(){
		try
		{
			serialPort = new SerialPort("COM5", 9600) // ⚠️ Vérifier le bon port COM ici
			{
				ReadTimeout = 500,  // Temps d'attente avant qu'une lecture échoue
				Handshake = Handshake.None, // Désactiver le contrôle de flux
				DtrEnable = true,  // Active Data Terminal Ready pour éviter le reset automatique de l'Arduino
				RtsEnable = true   // Active Request to Send
			};
			serialPort.Open();
			GD.Print("Port série ouvert avec succès !");
		}
		catch (Exception e)
		{
			GD.PrintErr($"Erreur d'ouverture du port : {e.Message}");
			serialPort = null;
		}
	}
	
	public void SendCharacter(char character){
		try
		{
			// Vérifier si le port série est ouvert
			if (serialPort != null && serialPort.IsOpen)
			{
				// Écrire le caractère sur le port série
				serialPort.Write(character.ToString());
				//GD.Print("Caractère envoyé : " + character);
			}
			else
			{
				GD.Print("Erreur : Port série non disponible !");
			}
		}
		catch (Exception ex)
		{
			GD.Print("Erreur lors de l'envoi du caractère : " + ex.Message);
		}
	}
	private void _on_button_toggled(bool toggled_on)
	{
		SendCharacter(toggled_on ? '1':'0');
	}
}

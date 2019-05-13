/*
  This macro will combine 3 batch analysis methods for NP distribution in ZF and export report files containing the data, an extensive log file and QC images in user defined folders. 
  Variables and parameters can be adjusted by dialogues, a batch mode is available.
  Analyses:
  1: accumulation in macrophages via flourescent region detection and measurement.
  2: accumulation in endothelia via flourescent region detection and measurement.
  3: circulation in the caudal vein by detection via flourescent vasculature or maually, followed by exclusion of accumulations and measurement.
*/
macro "Zebrafish particle distribution analysis" {
//get infos:
	//get filedata:
	dir1 = getDirectory("Please choose source directory ");
	list1 = getFileList(dir1);
	dir2 = getDirectory("_Please choose destination directory ");
	QCp = QCm = QCmp = QCap = QCex = QCe = QCep = QCf = false;
	step = stepP = stepM = stepW = stepE = stepO = stepAR = stepARR = false;
	//dialog for analysis type and options:
	Dialog.create("Analysis options");
	Dialog.addChoice("select analysis type: ", newArray("macrophage uptake", "endothelial uptake", "circulation"));
	Dialog.addMessage("define channel order:")
	Dialog.addChoice("endothelium: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"C1-");
	Dialog.addChoice("particles: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"C2-");
	Dialog.addChoice("macrophages: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"C3-");
	Dialog.addChoice("Transmission: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"C4-");
	Dialog.addChoice("marker5: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"not used");
	Dialog.addChoice("marker6: ", newArray("C1-", "C2-", "C3-", "C4-", "C5-", "C6-", "not used"),"not used");
	Dialog.addMessage("___________________________________");
	Dialog.addCheckbox("use batch mode ", true);
	Dialog.addCheckbox("use LUT's for Quality control images ", false);
	Dialog.addMessage("___________________________________");
	Dialog.addMessage("Advanced options:")
	Dialog.addCheckbox("alternate thresholding and detection values", false);
	Dialog.addCheckbox("Step-by-Step for whole analysis", false);
	Dialog.show();
	m=Dialog.getChoice();																			//variable for analysis method
	endo=Dialog.getChoice();
	par=Dialog.getChoice();
	mac=Dialog.getChoice();
	tra=Dialog.getChoice();
	mar5=Dialog.getChoice();
	mar6=Dialog.getChoice();
	batch = Dialog.getCheckbox();																	//variable for batch mode
	LUT = Dialog.getCheckbox();																		//variable for LUT on QC output images
	PRO = Dialog.getCheckbox();																		//variable for advanced options
	step=Dialog.getCheckbox();																		//variable for stepwise evaluation
	//dialog for output options in macrophage analysis:
	if(m=="macrophage uptake"){
		Dialog.create("Output options");
		Dialog.addString("name output file: ", "");
		Dialog.addCheckbox("delete exported single files after analysis ", true);
		Dialog.addMessage("Quality Control Options:");
		Dialog.addCheckbox("save Quality Control Image all options", true);
		Dialog.addMessage("or save Quality Control Image for inidvidual options:");
		Dialog.addCheckbox("particles ", false);
		Dialog.addSlider("B/C-Min:", 0, 3500, 0);
		Dialog.addSlider("B/C-Max:", 0, 3500, 250);
		Dialog.addCheckbox("macrophages ", false);
		Dialog.addSlider("B/C-Min:", 0, 3500, 0);
		Dialog.addSlider("B/C-Max:", 0, 3500, 700);
		Dialog.addCheckbox("macrophages on particles ", false);
		Dialog.addCheckbox("whole fish ", false);
		Dialog.addSlider("B/C-Min:", 0, 3500, 0);
		Dialog.addSlider("B/C-Max:", 0, 3500, 300);
		Dialog.show();
		v=Dialog.getString();																		//string results filename
		del = Dialog.getCheckbox();																	//variable for deletion of cached singlefiles after analysis
		QCa = Dialog.getCheckbox();																	//variable all QC options
		QCp = Dialog.getCheckbox();																	//variable QC of particles
		BCpA = Dialog.getNumber();																	//variable for B/C Min of QC of particles
		BCpB = Dialog.getNumber();																	//variable for B/C Max of QC of particles
		QCm = Dialog.getCheckbox();																	//variable QC of macrophages
		BCmA = Dialog.getNumber();																	//variable for B/C Min of QC of macrophages
		BCmB = Dialog.getNumber();																	//variable for B/C Max of QC of macrophages
		QCmp = Dialog.getCheckbox();																//variable QC of macrophage ROI on particle image
		QCf = Dialog.getCheckbox();																	//variable QC of whole fish
		BCwA = Dialog.getNumber();																	//variable for B/C Min of QC of whole fish
		BCwB = Dialog.getNumber();																	//variable for B/C Max of QC of whole fish
		//set "all" QC options
		if(QCa==true){
			QCp = QCm = QCmp = QCf = true;
		}
	}
		//dialog for output options in endothelial analysis:
		else if(m=="endothelial uptake"){
			Dialog.create("Output options");
			Dialog.addString("name output file: ", "");
			Dialog.addCheckbox("delete exported single files after analysis ", true);
			Dialog.addMessage("Quality Control Options:");
			Dialog.addCheckbox("save Quality Control Image all options", false);
			Dialog.addMessage("or save Quality Control Image for inidvidual options:");
			Dialog.addCheckbox("particles ", false);
			Dialog.addSlider("B/C-Min:", 0, 3500, 0);
			Dialog.addSlider("B/C-Max:", 0, 3500, 250);
			Dialog.addCheckbox("macrophages ", false);
			Dialog.addSlider("B/C-Min:", 0, 3500, 0);
			Dialog.addSlider("B/C-Max:", 0, 3500, 700);
			Dialog.addCheckbox("macrophages on particles ", false);
			Dialog.addCheckbox("endothelium ", false);
			Dialog.addSlider("B/C-Min:", 0, 3500, 0);
			Dialog.addSlider("B/C-Max:", 0, 3500, 900);
			Dialog.addCheckbox("endothelium on particles ", false);
			Dialog.addCheckbox("whole fish ", false);
			Dialog.addSlider("B/C-Min:", 0, 3500, 0);
			Dialog.addSlider("B/C-Max:", 0, 3500, 300);
			Dialog.show();
			v=Dialog.getString();																	//string results filename
			del = Dialog.getCheckbox();																//variable for deletion of cached singlefiles after analysis
			QCa = Dialog.getCheckbox();																//variable all QC options
			QCp = Dialog.getCheckbox();																//variable QC of particles
			BCpA = Dialog.getNumber();																//variable for B/C Min of QC of particles
			BCpB = Dialog.getNumber();																//variable for B/C Max of QC of particles
			QCm = Dialog.getCheckbox();																//variable QC of macrophages
			BCmA = Dialog.getNumber();																//variable for B/C Min of QC of macrophages
			BCmB = Dialog.getNumber();																//variable for B/C Max of QC of macrophages
			QCmp = Dialog.getCheckbox();															//variable QC of macrophage ROI on particle image
			QCe = Dialog.getCheckbox();																//variable QC of endothelium
			BCeA = Dialog.getNumber();																//variable for B/C Min of QC of endothelium
			BCeB = Dialog.getNumber();																//variable for B/C Max of QC of endothelium
			QCep = Dialog.getCheckbox();															//variable QC of endothelium ROI on particle image
			QCf = Dialog.getCheckbox();																//variable QC of whole fish
			BCwA = Dialog.getNumber();																//variable for B/C Min of QC of whole fish
			BCwB = Dialog.getNumber();																//variable for B/C Max of QC of whole fish
			//set "all" QC options
			if(QCa==true){
			QCp = QCm = QCmp = QCe = QCep = QCf = true;
			}
		}
			//dialog for output options in circulation analysis:
			else if(m=="circulation"){
				mart=false;
				mcro=false;
				Dialog.create("Output options");
				Dialog.addString("name output file: ", "");
				Dialog.addChoice("image orientation method: ", newArray("automatic (fli)", "manual"),"automatic (fli)");
				Dialog.addChoice("artery detection method: ", newArray("automatic (fli)", "manual"),"automatic (fli)");
				Dialog.addToSameRow();
				Dialog.addChoice("regions for manual artery detection: ", newArray("2", "3", "4", "5", "6", "7", "8" ,"9"),"5");
				Dialog.addCheckbox("delete exported single files after analysis ", true);
				Dialog.addMessage("Quality Control Options:");
				Dialog.addCheckbox("save Quality Control Image all options", true);
				Dialog.addMessage("or save Quality Control Image for inidvidual options:");
				Dialog.addCheckbox("artery on particles ", false);
				Dialog.addSlider("B/C-Min:", 0, 3500, 0);
				Dialog.addSlider("B/C-Max:", 0, 3500, 250);
				Dialog.addCheckbox("excluded particle signals ", false);
				Dialog.addCheckbox("whole fish ", false);
				Dialog.addSlider("B/C-Min:", 0, 3500, 0);
				Dialog.addSlider("B/C-Max:", 0, 3500, 300);
				Dialog.show();
				v=Dialog.getString();																//string results filename
				ori=Dialog.getChoice();
				am=Dialog.getChoice();																//variable for manual selection of artery
				rep = parseInt(Dialog.getChoice());													//variable for replications of manual selection of artery (increasing measured Area)
				del = Dialog.getCheckbox();															//variable for deletion of cached singlefiles after analysis
				QCa = Dialog.getCheckbox();															//variable all QC options
				BCpA = Dialog.getNumber();															//variable for B/C Min of QC of particles
				BCpB = Dialog.getNumber();															//variable for B/C Max of QC of particles
				QCap = Dialog.getCheckbox();														//variable QC of artery ROI on particle image
				QCex = Dialog.getCheckbox();														//variable QC of excluded particle ROI on particle image
				QCf = Dialog.getCheckbox();															//variable QC of whole fish
				BCwA = Dialog.getNumber();															//variable for B/C Min of QC of whole fish
				BCwB = Dialog.getNumber();															//variable for B/C Max of QC of whole fish
				if(ori=="manual"){
					mcro=true;																		//translation of string to boolean
				}
				if(am=="manual"){
					mart=true;																		//translation of string to boolean
				}
				//set "all" QC options
				if(QCa==true){
				QCp = QCm = QCap = QCex = QCe = QCep = QCf = true;
				}
			}
	//assign LUT's to channels
	if(LUT==true){
		Dialog.create("Assign LUT's");
		Dialog.addChoice("fli: ", newArray("Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", "Fire", "Ice", "16 colors", "Cyan Hot", "blue orange icb", "HiLo", "glow", "unionjack"));
		Dialog.addChoice("particles: ", newArray("Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", "Fire", "Ice", "16 colors", "Cyan Hot", "blue orange icb", "HiLo", "glow", "unionjack"));
		Dialog.addChoice("macrophages: ", newArray("Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", "Fire", "Ice", "16 colors", "Cyan Hot", "blue orange icb", "HiLo", "glow", "unionjack"));
		//further optinal channels:
			//Dialog.addChoice("C4: ", newArray("Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", "Fire", "Ice", "16 colors", "Cyan Hot", "blue orange icb", "HiLo", "glow", "unionjack"));
			//Dialog.addChoice("C5: ", newArray("Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", "Fire", "Ice", "16 colors", "Cyan Hot", "blue orange icb", "HiLo", "glow", "unionjack"));
		Dialog.show();
		C1=Dialog.getChoice();
		C2=Dialog.getChoice();
		C3=Dialog.getChoice();
		//further optinal channels:
			//C4=Dialog.getChoice();
			//C5=Dialog.getChoice();
	}
	if(PRO==true){
		//advanced options for macrophage uptake analysis
		if(m=="macrophage uptake"){
		//create dialog
			Dialog.create("advanced options");
		//get values for particle detection:
		  	Dialog.addMessage(" Particle Thresholding:");
		  	Dialog.addChoice("Particle Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Otsu");
		  	Dialog.addToSameRow();
		  	Dialog.addCheckbox("dark background ", true);
		  	Dialog.addSlider("Threshold Min:", 0, 65535, 161);
		  	Dialog.addToSameRow();
		  	Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
		  	Dialog.addCheckbox("Step-by-Step particle detection", false);
		  	Dialog.addMessage("___________________________________________________________________________________________________");
		  	Dialog.addMessage(" Particle Analysis:");
		  	Dialog.addCheckbox("include holes ", true);
			Dialog.addSlider("Size Min:", 0, 10000000, 15);
			Dialog.addToSameRow();
			Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
		  	Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
		  	Dialog.addToSameRow();
			Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
		  	Dialog.addMessage("___________________________________________________________________________________________________");
			Dialog.addSlider("particle detection background", 1.00, 200, 80);
		//get values for macrophage detection:
		  	Dialog.addMessage("___________________________________________________________________________________________________");
		  	Dialog.addMessage("___________________________________________________________________________________________________");
		  	Dialog.addMessage(" Macrophage Thresholding:");
		  	Dialog.addChoice("       Macrophage Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Otsu");
		  	Dialog.addToSameRow();
		  	Dialog.addCheckbox("dark background ", true);
		  	Dialog.addSlider("Threshold Min:", 0, 65535, 150);
		  	Dialog.addToSameRow();
		  	Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
		  	Dialog.addCheckbox("Step-by-Step macrophage detection", false);
		  	Dialog.addMessage("___________________________________________________________________________________________________");
		  	Dialog.addMessage(" Macrophage Analysis:");
		  	Dialog.addCheckbox("include holes ", false);
			Dialog.addSlider("Size Min:", 0, 10000000, 50);
			Dialog.addToSameRow();
			Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
		 	Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
		  	Dialog.addToSameRow();
			Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
			Dialog.addMessage("___________________________________________________________________________________________________");
			Dialog.addSlider("macrophage detection background", 1.00, 200, 19);
		//get values for whole fish detection:
			Dialog.addMessage("___________________________________________________________________________________________________");
			Dialog.addMessage("___________________________________________________________________________________________________");
			Dialog.addMessage(" Whole fish Thresholding:");
			Dialog.addCheckbox("find edges before Thresholding ", true);
			Dialog.addChoice("   Whole fish Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Triangle");
			Dialog.addToSameRow();
			Dialog.addCheckbox("dark background ", true);
			Dialog.addSlider("Threshold Min:", 0, 65535, 242);
			Dialog.addToSameRow();
			Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
			Dialog.addCheckbox("Step-by-Step Whole fish detection", false);
			Dialog.addMessage("___________________________________________________________________________________________________");
			Dialog.addMessage("Whole fish Analysis:");
			Dialog.addCheckbox("include holes ", true);
			Dialog.addSlider("Size Min:", 0, 10000000, 900000);
			Dialog.addToSameRow();
			Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
			Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.005);
			Dialog.addToSameRow();
			Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
			Dialog.show;
		//values for particle detection:
			TRmM = Dialog.getChoice();																//Thresholding method
			darkm = Dialog.getCheckbox();															//dark background option
			TRmA = Dialog.getNumber();																//Threshold Min
			TRmB = Dialog.getNumber();																//Threshold Max
			stepP = Dialog.getCheckbox();															//particle analysis steps
			PINCm = Dialog.getCheckbox();															//"include holes" option for particle analysis
			if(PINCm==true){																		//translate to string
				PINCm="include";
			}
				else{
					PINCm="";
				}
			PDmA = Dialog.getNumber();																//particle size min
			PDmB = Dialog.getNumber();																//particle size max
			if(PDmB==10000000){																		//translate to string
				PDmB="infinity";
			}
			PCmA = Dialog.getNumber();																//particle circularity min
			PCmB = Dialog.getNumber();																//particle circularity miax
			BGpmean = Dialog.getNumber();															//background value for ROI enlargement
		//values for macrophage detection:
			MTRmM = Dialog.getChoice();																//Thresholding method
			Mdarkm = Dialog.getCheckbox();															//dark background option
			MTRmA = Dialog.getNumber();																//Threshold Min
			MTRmB = Dialog.getNumber();																//Threshold Max
			stepM = Dialog.getCheckbox();															//macrophage analysis steps
			MINCm = Dialog.getCheckbox();															//"include holes" option for macrophage analysis
			if(MINCm==true){																		//translate to string
				MINCm="include";
			}
				else{
					MINCm="";
				}
			MPDmA = Dialog.getNumber();																//macrophage size min
			MPDmB = Dialog.getNumber();																//macrophage size max
			if(MPDmB==10000000){																	//translate to string
				MPDmB="infinity";
			}
			MPCmA = Dialog.getNumber();																//macrophage circularity min
			MPCmB = Dialog.getNumber();																//macrophage circularity max
			BGmmean = Dialog.getNumber();															//background value for ROI enlargement
		//values for whole fish detection:
			WefM = Dialog.getCheckbox();															//"find edges" option
			WTRM = Dialog.getChoice();																//Thresholding method
			Wdark = Dialog.getCheckbox();															//dark background option
			WTRA = Dialog.getNumber();																//Threshold Min
			WTRB = Dialog.getNumber();																//Threshold Max
			stepW = Dialog.getCheckbox();															//whole fish analysis steps
			WINC = Dialog.getCheckbox();															//"include holes" option for whole fish analysis
			if(WINC==true){																			//translate to string
				WINC="include";
			}
				else{
					WINC="";
				}
			WPDA = Dialog.getNumber();																//particle size min
			WPDB = Dialog.getNumber();																//particle size max
			if(WPDB==10000000){																		//translate to string
				WPDB="infinity";
			}
			WPCA = Dialog.getNumber();																//particle circularity min
			WPCB = Dialog.getNumber();																//particle circularity max
		}
			//advanced options for endothelial uptake analysis
			else if(m=="endothelial uptake"){
			//create dialogs
				Dialog.create("advanced options 1/2 [Particles and macrophages]");
			//get values for particle detection:
				Dialog.addMessage(" Particle Thresholding:");
				Dialog.addChoice("Particle Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Otsu");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 161);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addCheckbox("Step-by-Step particle detection", false);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage(" Particle Analysis:");
				Dialog.addCheckbox("include holes ", false);
				Dialog.addSlider("Size Min:", 0, 10000000, 5);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addSlider("particle detection background", 1.00, 200, 80);//18
			//get values for macrophage detection:
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage(" Macrophage Thresholding:");
				Dialog.addChoice("    	Macrophage Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Otsu");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 250);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addCheckbox("Step-by-Step macrophage detection", false);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Macrophage Analysis:");
				Dialog.addCheckbox("include holes ", false);
				Dialog.addSlider("Size Min:", 0, 10000000, 50);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addSlider("macrophage detection background", 1.00, 200, 18);
				Dialog.show;
//values for particle detection:
				TReM = Dialog.getChoice();															//Thresholding method
				darke = Dialog.getCheckbox();														//dark background option
				TReA = Dialog.getNumber();															//Threshold min
				TReB = Dialog.getNumber();															//Threshold Max
				stepP = Dialog.getCheckbox();														//particle analysis steps
				PINCe = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(PINCe==true){																	//translate to string
					PINCe="include";
				}
					else{
						PINCe="";
					}
				PDeA = Dialog.getNumber();															//particle size min
				PDeB = Dialog.getNumber();															//particle size max
				if(PDeB==10000000){																	//translate to string
					PDeB="infinity";
				}
				PCeA = Dialog.getNumber();															//particle circularity min
				PCeB = Dialog.getNumber();															//particle circularity max
				BGpmean = Dialog.getNumber();														//background value for ROI enlargement
	//values for macrophage detection:
				MTReM = Dialog.getChoice();															//Thresholding method
				Mdarke = Dialog.getCheckbox();														//dark background option
				MTReA = Dialog.getNumber();															//Threshold min
				MTReB = Dialog.getNumber();															//Threshold max
				stepM = Dialog.getCheckbox();														//macrophage analysis steps
				MINCe = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(MINCe==true){
					MINCe="include";
				}
					else{
						MINCe="";
					}
				MPDeA = Dialog.getNumber();															//particle size min
				MPDeB = Dialog.getNumber();															//particle size max
				if(MPDeB==10000000){																//translate to string
					MPDeB="infinity";
				}
				MPCeA = Dialog.getNumber();															//particle circularity min
				MPCeB = Dialog.getNumber();															//particle circularity max
				BGmmean = Dialog.getNumber();														//background value for ROI enlargement
	//get values for endothelium detection:
				Dialog.create("advanced options 2/2 [Endothelium and Whole fish]");
				Dialog.addMessage(" Endothelium Thresholding:");
				Dialog.addChoice("	    Endothelium Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Triangle");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 100);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addCheckbox("Step-by-Step endothelium detection", false);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Endothelium Analysis:");
				Dialog.addCheckbox("include holes ", false);
				Dialog.addSlider("Size Min:", 0, 10000000, 50);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
			//get values for whole fish detection:
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage(" Whole fish Thresholding:");
				Dialog.addCheckbox("find edges before Thresholding ", true);
				Dialog.addChoice("   Whole fish Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Triangle");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 242);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addCheckbox("Step-by-Step Whole fish detection", false);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Whole fish Analysis:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 900000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.005);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.show;
			//values for endothelium detection:
				ETReM = Dialog.getChoice();															//Thresholding method
				Edarke = Dialog.getCheckbox();														//dark background option
				ETReA = Dialog.getNumber();															//Threshold min
				ETReB = Dialog.getNumber();															//Threshold max
				stepE = Dialog.getCheckbox();														//endothelium analysis steps
				EINCe = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(EINCe==true){																	//translate to string
					EINCe="include";
				}
					else{
						EINCe="";
					}
				EPDeA = Dialog.getNumber();															//particle size min
				EPDeB = Dialog.getNumber();															//particle size max
				if(EPDeB==10000000){
					EPDeB="infinity";
				}
				EPCeA = Dialog.getNumber();															//particle circularity min
				EPCeB = Dialog.getNumber();															//particle circularity max
			//values for whole fish detection:
				WefM = Dialog.getCheckbox();														//"find edges" option
				WTRM = Dialog.getChoice();															//Thresholding method
				Wdark = Dialog.getCheckbox();														//dark background option
				WTRA = Dialog.getNumber();															//Threshold min
				WTRB = Dialog.getNumber();															//Threshold max
				stepW = Dialog.getCheckbox();														//Whole fish analysis steps
				WINC = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(WINC==true){																		//translate to string
					WINC="include";
				}
					else{
						WINC="";
					}
				WPDA = Dialog.getNumber();															//particle size min
				WPDB = Dialog.getNumber();															//particle size max
				if(WPDB==10000000){
					WPDB="infinity";
				}
				WPCA = Dialog.getNumber();															//particle circularity min
				WPCB = Dialog.getNumber();															//particle circularity max
			}
			//advanced options for circulation analysis
			else if(m=="circulation"){
			//create dialog window 1 of 3
				Dialog.create("Advanced Settings Page 1/3 [Orientation of the images]");
				Dialog.addMessage("Fish Detection :");
				Dialog.addCheckbox("Step-by-Step Orientation detection", false);
				Dialog.addChoice("Vertical Detection Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Yen");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 0);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 9509);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 5000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addSlider("Enlarge Selection Diameter:", 0, 5000, 50);
			//get values for segment detection:
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Segment Thresholding:");
				Dialog.addSlider("Overcontrasting:", 0.15, 100, 25);
				Dialog.addChoice(" Segment Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Percentile");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addMessage(" Auto Thresholding due to artificially generated variances needed");
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Segment Detection:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 2500);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 11000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("___________________________________________________________________________________________________");
			//get values for anastomotic vessle detection
				Dialog.addMessage("Anastomotic vessle Detection:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 100);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 1000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("___________________________________________________________________________________________________");
			//get values for caudal vein plexus detection
				Dialog.addMessage("Caudal Vein Plexus Detection:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 1000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("___________________________________________________________________________________________________");
			//get values for outline detection
				Dialog.addMessage("Outline Thresholding:");
				Dialog.addSlider("Blur Radius:", 0.01, 100, 10);
				Dialog.addChoice("	Outline Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "MinError");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 11);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Outline Detection:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 150000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.001);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.show;
			//get values from dialog:
			//values for fish detection:
				stepO = Dialog.getCheckbox();														//Whole fish analysis steps
				TRfM = Dialog.getChoice();															//Thresholding method
				darkf = Dialog.getCheckbox();														//dark background option
				TRfA = Dialog.getNumber();															//Threshold min
				TRfB = Dialog.getNumber();															//Threshold max
				INCf = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCf==true){																		//translate to string
					INCf="include";
				}
					else{
						INCf="";
					}
				PDfA = Dialog.getNumber();															//particle size min
				PDfB = Dialog.getNumber();															//particle size max
				if(PDfB==10000000){																	//translate to string
					PDfB="infinity";
				}
				PCfA = Dialog.getNumber();															//particle circularity min
				PCfB = Dialog.getNumber();															//particle circularity max
				ENLf = Dialog.getNumber();															//selection enlargement
			//values for segment detection:
				OCs = Dialog.getNumber();															//amount of overcontrasting (% saturated)
				TRsM = Dialog.getChoice();															//Thresholding method
				darks = Dialog.getCheckbox();														//dark background option
				INCs = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCs==true){																		//translate to string
					INCs="include";
				}
					else{
						INCs="";
					}
				PDsA = Dialog.getNumber();															//particle size min
				PDsB = Dialog.getNumber();															//particle size max
				if(PDsB==10000000){																	//translate to string
					PDsB="infinity";
				}
				PCsA = Dialog.getNumber();															//particle circularity min
				PCsB = Dialog.getNumber();															//particle circularity max
			//values for anastomotic vessle detection
				INCa = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCa==true){																		//translate to string
					INCa="include";
				}
					else{
						INCa="";
					}
				PDaA = Dialog.getNumber();															//particle size min
				PDaB = Dialog.getNumber();															//particle size max
				if(PDaB==10000000){																	//translate to string
					PDaB="infinity";
				}
				PCaA = Dialog.getNumber();															//particle circularity min
				PCaB = Dialog.getNumber();															//particle circularity max
			//values for caudal vein plexus detection
				INCc = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCc==true){																		//translate to string
					INCc="include";
				}
					else{
						INCc="";
					}
				PDcA = Dialog.getNumber();															//particle size min
				PDcB = Dialog.getNumber();															//particle size max
				if(PDcB==10000000){																	//translate to string
					PDcB="infinity";
				}
				PCcA = Dialog.getNumber();															//particle circularity min
				PCcB = Dialog.getNumber();															//particle circularity max
			//values for outline detection
				BLro = Dialog.getNumber();															//blur strength (Mean)
				TRoM = Dialog.getChoice();															//Thresholding method
				darko = Dialog.getCheckbox();														//dark background option
				TRoA = Dialog.getNumber();															//Threshold min
				TRoB = Dialog.getNumber();															//Threshold max
				INCo = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCo==true){																		//translate to string
					INCo="include";
				}
					else{
						INCo="";
					}
				PDoA = Dialog.getNumber();															//particle size min
				PDoB = Dialog.getNumber();															//particle size max
				if(PDoB==10000000){																	//translate to string
					PDoB="infinity";
				}
				PCoA = Dialog.getNumber();															//particle circularity min
				PCoB = Dialog.getNumber();															//particle circularity max
			//create dialog window 2 of 3
			//get values to generate artery ROI
				Dialog.create("Advanced Settings Page 2/3 [Artery ROI Generation]");
				Dialog.addMessage(" Segment Thresholding:");
				Dialog.addCheckbox("Step-by-Step artery ROI generation", false);
				Dialog.addSlider("Blur Radius:", 0.01, 100, 17);
				Dialog.addChoice("Segment Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Mean");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 6422);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("_______________________________________________________________________________________________________________________________________________________");
				Dialog.addMessage("Inverse Segment Selection:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 3000); //PDseA
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 8000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addMessage("_______________________________________________________________________________________________________________________________________________________");
				Dialog.addMessage("Artery ROI Generation:");
				Dialog.addSlider("artery width:", 0, 50, 13); //ARTw
				Dialog.addToSameRow();
				Dialog.addSlider("artery offset [px]:", 0, 100, 24); //ARTpx
				Dialog.addToSameRow();
				Dialog.addSlider("artery offset [°]:", -25, 25, -2); //ARTg
				Dialog.addMessage("_______________________________________________________________________________________________________________________________________________________");
				Dialog.addMessage("_______________________________________________________________________________________________________________________________________________________");
			//get values to shape artery ROI
				Dialog.addMessage("Intersegmental Vessle Exclusion:");
				Dialog.addSlider("Blur Radius:", 0.01, 100, 17);
				Dialog.addChoice("ISV Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Mean");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 6422);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("_______________________________________________________________________________________________________________________________________________________");
				Dialog.addMessage("ISV Analysis:");
				Dialog.addCheckbox("include holes ", false);
				Dialog.addSlider("Size Min:", 0, 10000000, 1000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 8000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addSlider("enlarge substraction of intersegmental vessle [px]:", 0, 50, 23); //ENLar = //24
				Dialog.show;
			//get values from dialog
			//values to generate artery ROI:
				stepAR = Dialog.getCheckbox();														//artery ROI generation steps
				BLrse = Dialog.getNumber();															//blur strength (Mean)
				TRseM = Dialog.getChoice();															//Thresholding method
				darkse = Dialog.getCheckbox();														//dark background option
				TRseA = Dialog.getNumber();															//Threshold min
				TRseB = Dialog.getNumber();															//Threshold max
				INCse = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCse==true){																	//translate to string
					INCse="include";
				}
					else{
						INCse="";
					}
				PDseA = Dialog.getNumber();															//particle size min
				PDseB = Dialog.getNumber();															//particle size max
				if(PDseB==10000000){																//translate to string
					PDseB="infinity";
				}
				PCseA = Dialog.getNumber();															//particle circularity min
				PCseB = Dialog.getNumber();															//particle circularity max
				ARTw = Dialog.getNumber();															//width of artery selection rectangle
				ARTpx = Dialog.getNumber();															//x position of artery selection rectangle
				ARTg = Dialog.getNumber();															//angle of artery selection rectangle
			//values to shape artery ROI
				BLrar = Dialog.getNumber();															//blur strength (Mean)
				TRarM = Dialog.getChoice();															//Thresholding method
				darkar = Dialog.getCheckbox();														//dark background option
				TRarA = Dialog.getNumber();															//Threshold min
				TRarB = Dialog.getNumber();															//Threshold max
				INCar = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCar==true){																	//translate to string
					INCar="include";
				}
					else{
						INCar="";
					}
				PDarA = Dialog.getNumber();															//particle size min
				PDarB = Dialog.getNumber();															//particle size max
				if(PDarB==10000000){																//translate to string
					PDarB="infinity";
				}
				PCarA = Dialog.getNumber();															//particle circularity min
				PCarB = Dialog.getNumber();															//particle circularity max
				ENLar = Dialog.getNumber();															//selection enlargement
			//create dialog window 2 of 3
			//get values to remove anastomotic regions + accumulations:
				Dialog.create("Advanced Settings Page 3/3 [Artery ROI refinement and whole fish detection]");
				Dialog.addMessage("Accumulation Thresholding:");
				Dialog.addCheckbox("Step-by-Step artery ROI refinement", false);
				Dialog.addChoice("Accumulation Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "IJ_IsoData");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 66);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Accumulation Analysis:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 1);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 800);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.addSlider("enlarge substraction of accumulations [px]:", 0, 15, 1);
			//get values to redefine artery ROI
				Dialog.addMessage(" refined Artery Thresholding:");
				Dialog.addChoice("refined Artery Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Triangle");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 1);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("refined Artery Analysis:");
				Dialog.addCheckbox("include holes ", false);
				Dialog.addSlider("Size Min:", 0, 10000000, 60);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 6000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.010);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
			//get values for whole fish detection:
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage(" Whole fish Thresholding:");
				Dialog.addCheckbox("Step-by-Step Whole fish detection", false);
				Dialog.addCheckbox("find edges before Thresholding ", true);
				Dialog.addChoice("   Whole fish Thresholding Method: ", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"), "Triangle");
				Dialog.addToSameRow();
				Dialog.addCheckbox("dark background ", true);
				Dialog.addSlider("Threshold Min:", 0, 65535, 242);
				Dialog.addToSameRow();
				Dialog.addSlider("Threshold Max:", 0, 65535, 65535);
				Dialog.addMessage("___________________________________________________________________________________________________");
				Dialog.addMessage("Whole fish Analysis:");
				Dialog.addCheckbox("include holes ", true);
				Dialog.addSlider("Size Min:", 0, 10000000, 900000);
				Dialog.addToSameRow();
				Dialog.addSlider("Size Max:", 0, 10000000, 10000000);
				Dialog.addSlider("Circularity Min:", 0.000, 1.000, 0.005);
				Dialog.addToSameRow();
				Dialog.addSlider("Circularity Max:", 0.000, 1.000, 0.999);
				Dialog.show;
			//get values:
			//values to remove anastomotic regions + accumulations:
				stepARR = Dialog.getCheckbox();														//artery ROI refinement steps
				TRanM = Dialog.getChoice();															//Thresholding method
				darkan = Dialog.getCheckbox();														//dark background option
				TRanA = Dialog.getNumber();															//Threshold min
				TRanB = Dialog.getNumber();															//Threshold max
				INCan = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCan==true){																	//translate to string
					INCan="include";
				}
					else{
						INCan="";
					}
				PDanA = Dialog.getNumber();															//particle size min
				PDanB = Dialog.getNumber();															//particle size max
				if(PDanB==10000000){																//translate to string
					PDanB="infinity";
				}
				PCanA = Dialog.getNumber();															//particle circularity min
				PCanB = Dialog.getNumber();															//particle circularity max
				ENLan = Dialog.getNumber();															//selection enlargement
			//values to redefine artery ROI
				TRafM = Dialog.getChoice();															//Thresholding method
				darkaf = Dialog.getCheckbox();														//dark background option
				TRafA = Dialog.getNumber();															//Threshold min
				TRafB = Dialog.getNumber();															//Threshold max
				INCaf = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(INCaf==true){																	//translate to string
					INCaf="include";
				}
					else{
						INCaf="";
					}
				PDafA = Dialog.getNumber();															//particle size min
				PDafB = Dialog.getNumber();															//particle size max
				if(PDafB==10000000){																//translate to string
					PDafB="infinity";
				}
				PCafA = Dialog.getNumber();															//particle circularity min
				PCafB = Dialog.getNumber();															//particle circularity max
			//values for whole fish detection:
				stepW = Dialog.getCheckbox();														//Whole fish analysis steps
				WefM = Dialog.getCheckbox();														//"find edges" option
				WTRM = Dialog.getChoice();															//Thresholding method
				Wdark = Dialog.getCheckbox();														//dark background option
				WTRA = Dialog.getNumber();															//Threshold min
				WTRB = Dialog.getNumber();															//Threshold max
				WINC = Dialog.getCheckbox();														//"include holes" option for particle analysis
				if(WINC==true){																		//translate to string
					WINC="include";
				}
					else{
						WINC="";
					}
				WPDA = Dialog.getNumber();															//particle size min
				WPDB = Dialog.getNumber();															//particle size max
				if(WPDB==10000000){																	//translate to string
					WPDB="infinity";
				}
				WPCA = Dialog.getNumber();															//particle circularity min
				WPCB = Dialog.getNumber();															//particle circularity max
			}
	}
		else{
	//if no advanced options following "standard" values will be used:
		//values for macrophage analysis:
		//particle detection
			TRmM = "Otsu";
			darkm = true;
			TRmA = 161;
			TRmB = 65535;
			PINCm = "include";
			PDmA = 15;
			PDmB = "infinity";
			PCmA = 0.010;
			PCmB = 1.000;
			BGpmean=80;
		//macrophage detection
			MTRmM = "Otsu";
			Mdarkm = true;
			MTRmA = 150;
			MTRmB = 65535;
			MINCm = "";
			MPDmA = 50;
			MPDmB = "infinity";
			MPCmA = 0.010;
			MPCmB = 1.000;
			BGmmean=19;
		//values for endothel analysis:
		//particle detection
			TReM = "Otsu";
			darke = true;
			TReA = 161;
			TReB = 65535;
			PINCe = "";
			PDeA = 5;
			PDeB = "infinity";
			PCeA = 0.010;
			PCeB = 1.000;
		//macrophage detection
			MTReM = "Otsu";
			Mdarke = true;
			MTReA = 250;
			MTReB = 65535;
			MINCe = "";
			MPDeA = 50;
			MPDeB = "infinity";
			MPCeA = 0.010;
			MPCeB = 1.000;
		//endothel detection
			ETReM = "Triangle";
			Edarke = true;
			ETReA = 100;
			ETReB = 65535;
			EINCe = "";
			EPDeA = 50;
			EPDeB = "infinity";
			EPCeA = 0.010;
			EPCeB = 1.000;
		//values for circulation analysis 1 (Orientation):
		//fish detection
			TRfM = "Yen";
			darkf = true;
			TRfA = 0;
			TRfB = 9509;
			INCf = "include";
			PDfA = 5000;
			PDfB = "infinity";
			PCfA = 0.010;
			PCfB = 1.000;
			ENLf = 50;
		//segment detection
			OCs = 25;
			TRsM = "Percentile";
			darks = true;
			INCs = "include";
			PDsA = 2500;
			PDsB = 11000;
			PCsA = 0.00;
			PCsB = 1.000;
		//anastomotic V detection
			INCa = "include";
			PDaA = 90;
			PDaB = 1500;
			PCaA = 0.010;
			PCaB = 1.000;
		//caudal vein plexus detection
			INCc = "include";
			PDcA = 1000;
			PDcB = 10000;
			PCcA = 0.010;
			PCcB = 1.000;
		//outline detection
			BLro = 10;
			TRoM = "MinError";
			darko = true;
			TRoA = 11;
			TRoB = 65535;
			INCo = "include";
			PDoA = 150000;
			PDoB = "infinity";
			PCoA = 0.001;
			PCoB = 1.000;
		//values for circulation analysis 2 (Detection):
		//generate artery ROI
			BLrse = 17;
			TRseM = "Mean";
			darkse = true;
			TRseA = 6422;
			TRseB = 65535;
			INCse = "include";
			PDseA = 3000;
			PDseB = 8000;
			PCseA = 0.01;
			PCseB = 1;
			ARTw = 13;
			ARTpx = 26;
			ARTg = -2;
		//shape artery ROI
			BLrar = 17;
			TRarM = "Mean";
			darkar = true;
			TRarA = 6422;
			TRarB = 65535;
			INCar = "";
			PDarA = 1500;
			PDarB = 8000;
			PCarA = 0.01;
			PCarB = 1;
			ENLar = 24;
		//remove anastomotic regions + accumulations
			TRanM = "IJ_IsoData";
			darkan = true;
			TRanA = 90;
			TRanB = 65535;
			INCan = "include";
			PDanA = 1;
			PDanB = 350;
			PCanA = 0.01;
			PCanB = 1;
			ENLan = 1;
		//redefining artery ROI
			TRafM = "Triangle";
			darkaf = true;
			TRafA = 1;
			TRafB = 65535;
			INCaf = "";
			PDafA = 60;
			PDafB = 6000;
			PCafA = 0.00;
			PCafB = 1.00;
		//whole fish detection
			WefM = true;
			WTRM = "Triangle";
			Wdark = true;
			WTRA = 242;
			WTRB = 65535;
			WINC = "include";
			WPDA = 900000;
			WPDB = "infinity";
			WPCA = 0.005;
			WPCB = 1.000;
		}
	//reset system:
	run("Close All");
	print("\\Clear");
	print("Reset: log, Results, ROI Manager");
	run("Clear Results");
	updateResults;
	roiManager("reset");
	while (nImages>0) {					//del single ROIs
		selectImage(nImages);
		close();
	}
	print("_");
	getDateAndTime(year, month, week, day, hour, min, sec, msec);
	print("Starting analysis at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
	print("_");
	print("analysis method = "+m+"");
	if(PRO==true){
		print("using user defined values for Thresholding and detection");
	}
	print("_");
	//reset counter for final message
	N=0;
	//make output dirs / check for write permission (generated dir exists):
	print("Writing output directories:");
	singledirH = dir2 + "HighMag_files" + File.separator;
	singledirL = dir2 + "LowMag_files" + File.separator;
	Resdir = dir2 + "Data" + File.separator;
	QCdir = dir2 + "Qualitycontrol" + File.separator;
	CACHE = dir2 + "CACHE" + File.separator;
	print(singledirH);
	File.makeDirectory(singledirH);
	if (!File.exists(singledirH))
		exit("Unable to create directory - check permissions");
	print(singledirL);
	File.makeDirectory(singledirL);
	if (!File.exists(singledirL))
		exit("Unable to create directory - check permissions");
	print(Resdir);
	File.makeDirectory(Resdir);
	if (!File.exists(Resdir))
		exit("Unable to create directory - check permissions");
	if((QCp|QCm|QCmp|QCap|QCex|QCe|QCep|QCf) == true){
		print(QCdir);
		File.makeDirectory(QCdir);
			if (!File.exists(QCdir))
				exit("Unable to create directory - check permissions");
	}
	if (batch==true){
		setBatchMode(true);
		print("running in batch mode");
		print("_");
	}
	//extract *.lif to singlefiles *.tif
	for (j=0; j<list1.length; j++) {
		path1 = dir1+list1[j];
		print("start processing of "+path1+"");
		print("_");
		print("exporting images:");
		run("Bio-Formats Importer", "open=[path1] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT open_all_series");
	//sort images by pixelsize (values can be adapted[in this case: high mag about 0.85 / low mag about 3]):
		while (nImages>0) {					//del single ROIs
			selectImage(nImages);
			getPixelSize(unit, pixelWidth, pixelHeight);
			if(pixelWidth>=1){
				titleS= getTitle;
				print("converting low mag image:"+titleS+"");
				saveAs("tif", singledirL+titleS+".tif");
				close();
			}
				else{
					titleS= getTitle;
					print("converting high mag image:"+titleS+"");
					saveAs("tif", singledirH+titleS+".tif");
					close();
				}
		}
		print("_");
	}
	print("finished exporting single files");
	print("_");
	//macrophage accumulation analysis:
	if(m=="macrophage uptake"){
	//analyse high Mag images:
		listH = getFileList(singledirH);
		nImg=listH.length*2;
		print("detecting macrophage uptake");
		for (i=0; i<listH.length; i++) {
			roiManager("reset");
			path = singledirH+listH[i];
			run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
			title1= getTitle;
			title2 = File.nameWithoutExtension;
			Nrep=N+1;
			print("ANALYSING IMAGE "+Nrep+" of "+nImg+"");
			print("analysing high mag image "+title1+":");
			run("Split Channels");
	//particles:
			print("deleting particle background");
			print("thresholding method: "+TRmM+", with min "+TRmA+" and max "+TRmB+"");
			selectWindow(""+par+""+title1+"");
			run("Duplicate...", " ");
			selectWindow(""+par+""+title2+"-1.tif");
			setAutoThreshold(""+TRmM+"");
			setThreshold(TRmA, TRmB);
			if(darkm==true){
				setOption("BlackBackground", true);
			}
			run("Convert to Mask");
			run("Make Binary");
			if((step==true)|(stepP==true)){
				setBatchMode("show");
				waitForUser("particle background Threshold for image"+title1+"");
			}
			run("Analyze Particles...", "size="+PDmA+"-"+PDmB+" circularity="+PCmA+"-"+PCmB+" "+PINCm+" add");
			if(roiManager("count") == 0){
				setBatchMode("show");
				print("________________");
				print("STOPPING MACRO");
				print("________________");
				print("ERROR: Unable to detect particle signal in "+title1+"");
				exit("ERROR: Unable to detect particle signal in "+title1+"");
			}
			if((step==true)|(stepP==true)){
				setBatchMode("show");
				waitForUser("initial particle ROI for image"+title1+"");
			}
			selectWindow(""+par+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			ENLstep=1;
			pROI=roiManager("count");
			IJ.renameResults("mResOUT");		//rename for enlarge measurements
	//enlarge detected area pixelwise
			for (r=0; r<pROI; r++) {
				roiManager("select", r);
				run("Clear", "slice");			//del content
				run("Enlarge...", "enlarge="+ENLstep+"");
				run("Set Measurements...", "area mean integrated redirect=None decimal=4");	
				run("Measure");					//measure added signal to area
				List.setMeasurements;
				Rmean = List.getValue("Mean");
				while(Rmean>BGpmean){			//compare signals and while addition is over treshold repeat
					run("Clear", "slice");		//del new content
					run("Enlarge...", "enlarge="+ENLstep+"");
					roiManager("Update");
					run("Set Measurements...", "area mean integrated redirect=None decimal=4");
					run("Measure");
					List.setMeasurements;
					Rmean = List.getValue("Mean");
					run("Clear Results");
					updateResults;
				}
				run("Clear Results");
				updateResults;
			if((step==true)|(stepP==true)){
				setMinAndMax(0, 120);
				setBatchMode("show");
				waitForUser("enlarged single accumulation ROI ["+r+"] for image"+title1+"");
			}
			}
			roiManager("Select", newArray());
			run("Select All");
			roiManager("Combine");
			roiManager("Add");
			roiManager("deselect");
		ROIc = roiManager("count");
		while (ROIc!=1) {						//del single ROIs
			roiManager("select", 0);
			roiManager("delete");
			ROIc = roiManager("count");
		}
			roiManager("deselect");
			selectWindow(""+par+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			setMinAndMax(BCpA, BCpB);
			roiManager("deselect");
			if(LUT==true){						//LUT for QC
				run("Duplicate...", " ");
				run("8-bit");
				run(C2);
			}
			roiManager("Select", 0);
			if(batch == false){
				wait(10);
			}
			run("Flatten");
			if(QCp == true){
				print("QC: saving particle signal/ROI");
				saveAs("Gif", QCdir+title2+"_02_Particles.gif");
			}
	//to get Thresholded image:
			selectWindow(""+par+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			roiManager("Select", 0);
			if((step==true)|(stepP==true)){
				setBatchMode("show");
				waitForUser("particle background ROI for image"+title1+"");
			}
		 run("Clear Outside", "slice");
			run("Select None");
			run("Duplicate...", " ");
			titleX=getTitle;
			roiManager("reset");
			run("Duplicate...", " ");
			if((step==true)|(stepP==true)){
				setBatchMode("show");
				waitForUser("particle background substracted for image"+title1+"");
			}
	//macrophages:
			act="macrophages";
			print("detecting macrophage signal");
			print("thresholding method: "+MTRmM+", with min "+MTRmA+" and max "+MTRmB+"");
			selectWindow(""+mac+""+title1+"");
			run("Duplicate...", " ");
			setAutoThreshold(""+MTRmM+"");
			setThreshold(MTRmA, MTRmB);
			if(Mdarkm==true){
				setOption("BlackBackground", true);
			}
			run("Convert to Mask");
			run("Make Binary");
			if((step==true)|(stepM==true)){
				setBatchMode("show");
				waitForUser("macrophage Threshold for image"+title1+"");
			}
			run("Analyze Particles...", "size="+MPDmA+"-"+MPDmB+" circularity="+MPCmA+"-"+MPCmB+" "+MINCm+" add");
			if(roiManager("count") == 0){
				setBatchMode("show");
				print("________________");
				print("STOPPING MACRO");
				print("________________");
				print("ERROR: Unable to detect macrophage signal in "+title1+"");
				exit("ERROR: Unable to detect macrophage signal in "+title1+"");
			}
			if((step==true)|(stepM==true)){
				setBatchMode("show");
				waitForUser("initial macrophage ROI for image"+title1+"");
			}
			selectWindow(""+mac+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			ENLstep=1;
			pROI=roiManager("count");
			for (r=0; r<pROI; r++) {
				roiManager("select", r);
				run("Clear", "slice");			//del content
				run("Enlarge...", "enlarge="+ENLstep+"");
				run("Set Measurements...", "area mean integrated redirect=None decimal=4");
				run("Measure");					//measure added signal to area
				List.setMeasurements;
				Rmean = List.getValue("Mean");
				while(Rmean>BGmmean){			//compare signals and while addition is over treshold repeat
					run("Clear", "slice");		//del new content
					run("Enlarge...", "enlarge="+ENLstep+"");
					roiManager("Update");
					run("Set Measurements...", "area mean integrated redirect=None decimal=4");
					run("Measure");
					List.setMeasurements;
					Rmean = List.getValue("Mean");
					run("Clear Results");
					updateResults;
				}
				run("Clear Results");
				updateResults;
			if((step==true)|(stepM==true)){
				setMinAndMax(0, 120);
				setBatchMode("show");
				waitForUser("enlarged single ROI ["+r+"] for image"+title1+"");
			}
			}
			roiManager("Select", newArray());
			run("Select All");
			roiManager("Combine");
			roiManager("Add");
			roiManager("deselect");
			ROIc = roiManager("count");
			while (ROIc!=1) {					//del single ROIs
				roiManager("select", 0);
				roiManager("delete");
				ROIc = roiManager("count");
			}
			selectWindow(""+mac+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			if(LUT==true){						//LUT for QC
				run("Duplicate...", " ");
				run("8-bit");
				run(C3);
			}
			setMinAndMax(BCmA, BCmB);
			roiManager("deselect");
			roiManager("Select", 0);
			if((step==true)|(stepM==true)){
				setBatchMode("show");
				waitForUser("macrophage ROI for image"+title1+"");
			}
			run("Flatten");
			if(QCm == true){
				print("QC: saving macrophage signal");
				saveAs("Gif", QCdir+title2+"_03_Macrop.gif");
			}
			if(batch==false){
			close();
			}
			selectWindow(""+par+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			setMinAndMax(BCpA, BCpB);
			roiManager("deselect");
			if(LUT==true){
				run("Duplicate...", " ");
				run("8-bit");
				run(C2);
			}
			roiManager("Select", 0);
			if(batch == false){
				wait(10);
			}
			run("Flatten");
			if(QCmp == true){
				print("QC: saving macrophage ROI / particle signal");
				saveAs("Gif", QCdir+title2+"_04_M-P-Overlay.gif");
			}
			if(batch==false){
			close();
			}
			ROIc = roiManager("count");
			while (ROIc!=1) {
				roiManager("select", 0);
				roiManager("delete");
				ROIc = roiManager("count");
			}
			selectWindow("mResOUT");
			IJ.renameResults("Results");		//rename for output measurements
			print("measuring");
			run("Set Measurements...", "area mean integrated redirect=None decimal=4");
			selectWindow(""+titleX+"");			//title for output in results
			if((step==true)|(stepP==true)|(stepM==true)){
				run("Select None");
				roiManager("deselect");
				roiManager("select",0);
				setBatchMode("show");
				waitForUser("measured area for "+title1+"");
				run("Select None");
				roiManager("deselect");
			}
			run("Select None");
			roiManager("deselect");
			actimage = getTitle();
			roiManager("select",0);
			run("Measure");
			setResult("filename", nResults-1, actimage);
			setResult("measured ROI", nResults-1, act);
			updateResults();
			roiManager("reset");
			print("_");
			while (nImages>0) {					//del single ROIs
				selectImage(nImages);
				close();
			}
			N=N+1;
		}
			print("saving results from "+N+" high mag images to "+Resdir+v+"_Macrophages.xls");
			selectWindow("Results");
			saveAs("txt", Resdir+v+"_Macrophages.xls");
			print("_");
			run("Clear Results");
			updateResults;
	}
	//analysis for endothelial uptake:
		else if(m=="endothelial uptake"){
	//analyse high Mag images:
			listH = getFileList(singledirH);
			nImg=listH.length*2;
			print("analysing endothelial uptake");
			print("_");
			for (i=0; i<listH.length; i++) {
				roiManager("reset");
				path = singledirH+listH[i];
				run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
				title1= getTitle;
				title2 = File.nameWithoutExtension;
				Nrep=N+1;
				print("ANALYSING IMAGE "+Nrep+" of "+nImg+"");
				print("analysing high mag image "+title1+":");
				run("Split Channels");
	//particles:
				print("deleting particle background");
				print("thresholding method: "+TReM+", with min "+TReA+" and max "+TReB+"");
				selectWindow(""+par+""+title1+"");
				run("Duplicate...", " ");
				setAutoThreshold(""+TReM+"");
				setThreshold(TReA, TReB);
				if(darke==true){
					setOption("BlackBackground", true);
				}
				run("Convert to Mask");
				run("Make Binary");
				if((step==true)|(stepP==true)){
					setBatchMode("show");
					waitForUser("particle background Threshold for image"+title1+"");
				}
				run("Analyze Particles...", "size="+PDeA+"-"+PDeB+" circularity="+PCeA+"-"+PCeB+" "+PINCe+" add");
				if(roiManager("count") == 0){
					setBatchMode("show");
					print("________________");
					print("STOPPING MACRO");
					print("________________");
					print("ERROR: Unable to detect particle signal in "+title1+"");
					exit("ERROR: Unable to detect particle signal in "+title1+"");
				}
			if((step==true)|(stepP==true)){
				setBatchMode("show");
				waitForUser("initial particle ROI for image"+title1+"");
			}
			selectWindow(""+par+""+title1+"");
			run("Select None");
			run("Duplicate...", " ");
			ENLstep=1;
			pROI=roiManager("count");
			IJ.renameResults("eResOUT");			//rename for enlarge measurements
			for (r=0; r<pROI; r++) {
				roiManager("select", r);
				run("Clear", "slice");				//del content
				run("Enlarge...", "enlarge="+ENLstep+"");
				run("Set Measurements...", "area mean integrated redirect=None decimal=4");
				run("Measure");						//measure added signal to area
				List.setMeasurements;
				Rmean = List.getValue("Mean");
				while(Rmean>BGpmean){				//compare signals and while addition is over treshold repeat
					run("Clear", "slice");			//del new content
					run("Enlarge...", "enlarge="+ENLstep+"");
					roiManager("Update");
					run("Set Measurements...", "area mean integrated redirect=None decimal=4");
					run("Measure");
					List.setMeasurements;
					Rmean = List.getValue("Mean");
					run("Clear Results");
					updateResults;
				}
				run("Clear Results");
				updateResults;
			if((step==true)|(stepP==true)){
				setMinAndMax(0, 120);
				setBatchMode("show");
				waitForUser("enlarged single accumulation ROI ["+r+"] for image"+title1+"");
			}
			}
				roiManager("Select", newArray());
				run("Select All");
				roiManager("Combine");
				roiManager("Add");
				roiManager("deselect");
				ROIc = roiManager("count");
				while (ROIc!=1) {					//del single ROIs
					roiManager("select", 0);
					roiManager("delete");
					ROIc = roiManager("count");
				}
				roiManager("deselect");
				selectWindow(""+par+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				setMinAndMax(BCpA, BCpB);
				if(LUT==true){						//LUT for QC
					run("Duplicate...", " ");
					run("8-bit");
					run(C2);
				}
				roiManager("Select", 0);
				if((step==true)|(stepP==true)){
					setBatchMode("show");
					waitForUser("particle background ROI for image"+title1+"");
				}
				if(batch == false){
				wait(10);
				}
				run("Flatten");
				if(QCp == true){
					print("QC: saving particle signal/ROI");
					saveAs("Gif", QCdir+title2+"_02_Particles.gif");
				}
				roiManager("deselect");
				selectWindow(""+par+""+title1+"");
				run("Select None");
				roiManager("Select", 0);
				run("Make Inverse");
				setBackgroundColor(0, 0, 0);
				run("Clear", "slice");
				roiManager("reset");
				run("Select None");
				roiManager("reset");
	//macrophages:
				print("detecting macrophage signal");
				print("thresholding method: "+MTReM+", with min "+MTReA+" and max "+MTReB+"");
				selectWindow(""+mac+""+title1+"");
				run("Duplicate...", " ");
				setAutoThreshold(""+MTReM+"");
				setThreshold(MTReA, MTReB);
				if(Mdarke==true){
					setOption("BlackBackground", true);
				}
				run("Convert to Mask");
				run("Make Binary");
				if((step==true)|(stepM==true)){
					setBatchMode("show");
					waitForUser("macrophage Threshold for image"+title1+"");
				}
				run("Analyze Particles...", "size="+MPDeA+"-"+MPDeB+" circularity="+MPCeA+"-"+MPCeB+" "+MINCe+" add");
				if(roiManager("count") == 0){
					setBatchMode("show");
					print("________________");
					print("STOPPING MACRO");
					print("________________");
					print("ERROR: Unable to detect macrophage signal in "+title1+"");
					exit("ERROR: Unable to detect macrophage signal in "+title1+"");
				}
				if((step==true)|(stepM==true)){
					setBatchMode("show");
					waitForUser("initial macrophage ROI for image"+title1+"");
				}
				selectWindow(""+mac+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				ENLstep=1;
				pROI=roiManager("count");
				for (r=0; r<pROI; r++) {
					roiManager("select", r);
					run("Clear", "slice");			//del content
					run("Enlarge...", "enlarge="+ENLstep+"");
					run("Set Measurements...", "area mean integrated redirect=None decimal=4");
					run("Measure");					//measure added signal to area
					List.setMeasurements;
					Rmean = List.getValue("Mean");
					while(Rmean>BGmmean){			//compare signals and while addition is over treshold repeat
						run("Clear", "slice");		//del new content
						run("Enlarge...", "enlarge="+ENLstep+"");
						roiManager("Update");
						run("Set Measurements...", "area mean integrated redirect=None decimal=4");
						run("Measure");
						List.setMeasurements;
						Rmean = List.getValue("Mean");
						run("Clear Results");
						updateResults;
					}
					run("Clear Results");
					updateResults;
				if((step==true)|(stepM==true)){
					setMinAndMax(0, 120);
					setBatchMode("show");
					waitForUser("enlarged single macrophage ROI ["+r+"] for image"+title1+"");
				}
				}
				roiManager("Select", newArray());
				run("Select All");
				roiManager("Combine");
				roiManager("Add");
				roiManager("deselect");
				ROIc = roiManager("count");
				while (ROIc!=1) {					//del single ROIs
					roiManager("select", 0);
					roiManager("delete");
					ROIc = roiManager("count");
				}
				selectWindow(""+mac+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				if(LUT==true){						//LUT for QC
					run("Duplicate...", " ");
					run("8-bit");
					run(C3);
				}
				setMinAndMax(BCmA, BCmB);
				roiManager("deselect");
				roiManager("Select", 0);
				if((step==true)|(stepM==true)){
					setBatchMode("show");
					waitForUser("refined macrophage ROI for image"+title1+"");
				}
				if(batch == false){
					wait(10);
				}
				run("Flatten");
				if(QCm == true){
					print("QC: saving macrophage signal / ROI");
					saveAs("Gif", QCdir+title2+"_03_Macrop.gif");
				}
				if(batch==false){
				close();
				}
				roiManager("deselect");
				selectWindow(""+par+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				if(LUT==true){
					run("Duplicate...", " ");
					run("8-bit");
					run(C2);
				}
				setMinAndMax(BCpA, BCpB);
				roiManager("Select", 0);
				if(batch == false){
				wait(10);
				}
				run("Flatten");
				if(QCmp == true){
					print("QC: saving macrophage ROI / particle signal");
					saveAs("Gif", QCdir+title2+"_04_M-P-Overlay.gif");
				}
				if(batch==false){
				close();
				}
				roiManager("deselect");
				ROIc = roiManager("count");
				while (ROIc!=1) {					//del single ROIs
					roiManager("select", 0);
					roiManager("delete");
					ROIc = roiManager("count");
				}
				print("deleting particle signals in macrophages");
				selectWindow(""+par+""+title1+"");
				run("Select None");
				roiManager("deselect");
				roiManager("select",0);
				setBackgroundColor(0, 0, 0);
				run("Clear", "slice");
				if((step==true)|(stepM==true)){
					setBatchMode("show");
					waitForUser("particles in macrophage ROI substracted for image"+title1+"");
				}
				run("Select None");
				noM=getTitle();
				roiManager("delete");
	//endothelium:
				act="endothelium";
				print("detecting endothelium signal");
				print("thresholding method: "+ETReM+", with min "+ETReA+" and max "+ETReB+"");
				selectWindow(""+endo+""+title1+"");
				run("Duplicate...", " ");
				setAutoThreshold(""+ETReM+"");
				setThreshold(ETReA, ETReB);
				if(Edarke==true){
					setOption("BlackBackground", true);
				}
				run("Convert to Mask");
				run("Make Binary");
				run("Invert");
				if((step==true)|(stepE==true)){
					setBatchMode("show");
					waitForUser("endothelium Threshold for image"+title1+"");
				}
				run("Analyze Particles...", "size="+EPDeA+"-"+EPDeB+" circularity="+EPCeA+"-"+EPCeB+" "+EINCe+" add");
				if(roiManager("count") == 0){
					setBatchMode("show");
					print("________________");
					print("STOPPING MACRO");
					print("________________");
					print("ERROR: Unable to detect particle signal in "+title1+"");
					exit("ERROR: Unable to detect particle signal in "+title1+"");
				}
				roiManager("Select", newArray());
				run("Select All");
				roiManager("Combine");
				roiManager("Add");
				run("Make Inverse");
				roiManager("Add");
				roiManager("deselect");
				ROIc = roiManager("count");
				while (ROIc!=1) {					//del single ROIs
					roiManager("select", 0);
					roiManager("delete");
					ROIc = roiManager("count");
				}
				roiManager("deselect");
				selectWindow(""+endo+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				if(LUT==true){
					run("Duplicate...", " ");
					run("8-bit");
					run(C1);
				}
				setMinAndMax(BCeA, BCeB);
				roiManager("Select", 0);
				if((step==true)|(stepE==true)){
					setBatchMode("show");
					waitForUser("endothelium ROI for image"+title1+"");
				}
				if(batch == false){
					wait(500);
				}	else{
						wait(10);
					}
				run("Flatten");
				if(QCe == true){
					print("QC: saving endothelium /ROI");
					saveAs("Gif", QCdir+title2+"_05_Endothel.gif");
				}
				if(batch==false){
				close();
				}
				roiManager("deselect");
				selectWindow(""+par+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				if(LUT==true){
					run("Duplicate...", " ");
					run("8-bit");
					run(C2);
				}
				setMinAndMax(BCpA, BCpB);
				roiManager("Select", 0);
				if(batch == false){
					wait(50);
				}	else{
						wait(10);
					}
				run("Flatten");
				if(QCep == true){
					print("QC: saving endothelium ROI / particle signal");
					saveAs("Gif", QCdir+title2+"_06_Endo-Overlay.gif");
				}
				if(batch==false){
				close();
				}
				selectWindow("eResOUT");
				IJ.renameResults("Results");		//rename for output measurements
				selectWindow(""+par+""+title1+"");
				run("Select None");
				run("Duplicate...", " ");
				roiManager("deselect");
				roiManager("Select", 0);
				print("measuring endothelial particle signal");
				run("Set Measurements...", "area mean integrated redirect=None decimal=4");
				selectWindow(""+par+""+title1+"");
				actimage = getTitle();				//title for output in results
				roiManager("select",0);
				if((step==true)|(stepM==true)|(stepE==true)){
					setBatchMode("show");
					waitForUser("measured ROI for image"+title1+"");
				}
				run("Measure");
				setResult("filename", nResults-1, actimage);
				setResult("measured ROI", nResults-1, act);
				updateResults();
				roiManager("deselect");
				roiManager("delete");
				while (nImages>0) {					//del single ROIs
					selectImage(nImages);
					close();
				}
				print("_");
				N=N+1;
				}
				print("saving results from "+N+" high mag images to "+Resdir+v+"_Macrophages.xls");
				print("_");
				selectWindow("Results");
				saveAs("txt", Resdir+v+"_endothelium.xls");
				run("Clear Results");
				updateResults;
			}
	//analysis for circulation:
				else if(m=="circulation"){
					listH = getFileList(singledirH);
					nImg=listH.length;
					if(mcro==true){
						print("manual image orientation before analysis:");
					}	else{
						print("adjusting image orientation before analysis:");	
					}
					print("_");
						for (j=0; j<listH.length; j++) {
							roiManager("reset");
							path = singledirH+listH[j];
							run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
							title1= getTitle;
							title2 = File.nameWithoutExtension;
							Jrep=j+1;
							print("IMAGE "+Jrep+" of "+nImg+"");
							if(mcro==false){
								print("analysing orientation of image "+title1+":");
								run("Split Channels");
								selectWindow(""+endo+""+title1+"");
								run("Duplicate...", " ");
								print("selecting central x-slice");
								makeRectangle(239, 0, 548, 1040);			//central slice gives most relieable signals as tail and partly imaged segments are omitted
								run("Crop");
								run("Duplicate...", " ");
								print("adjusting signal to noise ratio of fli signal via FFT Bandpass filter");	
								print("FFT done");
								run("Bandpass Filter...", "filter_large=500 filter_small=2 suppress=None tolerance=20 autoscale saturate");	//fft supresses signals from branching vessels from ISVs
								run("Enhance Contrast...", "saturated=15");
			//detect fish in y
								print("detecting fish on vertical axis");
								print("thresholding method: "+TRfM+", with min "+TRfA+" and max "+TRfB+"");
								setAutoThreshold(""+TRfM+"");
								setThreshold(TRfA, TRfB);;
								if(darkf==true){
									setOption("BlackBackground", true);
								}
								run("Convert to Mask");
								run("Invert");
								run("Analyze Particles...", "size="+PDfA+"-"+PDfB+" circularity="+PCfA+"-"+PCfB+" "+INCf+" add");
								if(roiManager("count") == 0){
									setBatchMode("show");
									print("________________");
									print("STOPPING MACRO");
									print("________________");
									print("ERROR0: Unable to detect fish outline in "+title1+"");
									exit("ERROR0: Unable to detect fish outline in "+title1+"");
								}
								roiManager("Select", 0);
								run("To Bounding Box");
								run("Enlarge...", "enlarge="+ENLf+"");
								roiManager("Add");
								ROIc = roiManager("count");
								while (ROIc!=1) {
									roiManager("select", 0);
									roiManager("delete");
									ROIc = roiManager("count");
								}
			//cut out fish region and turn for segment selection
								selectWindow(""+endo+""+title2+"-1.tif");
								roiManager("Select", 0);
								run("Duplicate...", " ");
								run("Duplicate...", " ");
								run("Rotate 90 Degrees Right");
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("selected region for image orientation for image"+title1+"");
								}
								roiManager("reset");
			//select segment to analyse
								run("Enhance Contrast...", "saturated="+OCs+"");
								print("adjusting signal to noise ratio of selected region via FFT Bandpass filter");
								run("Bandpass Filter...", "filter_large=500 filter_small=2 suppress=None tolerance=20 autoscale saturate");		//fft supresses signals from branching vessels from ISVs
								print("detecting segments");
								print("thresholding method: "+TRsM+", auto Thresholding");
								run("Enhance Contrast...", "saturated="+OCs+"");
								setAutoThreshold(""+TRsM+"");
								if(darks==true){
									setOption("BlackBackground", true);
								}
								run("Convert to Mask");
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("tesholded region for image orientation for image"+title1+"");
								}
								run("Dilate");
								run("Open");
								setOption("BlackBackground", true);
								run("Dilate");
								run("Analyze Particles...", "size="+PDsA+"-"+PDsB+" circularity="+PCsA+"-"+PCsB+" "+INCs+" add");
								if(roiManager("count") == 0){
									setBatchMode("show");
									print("________________");
									print("STOPPING MACRO");
									print("________________");
									print("ERROR: Unable to detect muscle segments in "+title1+"");
									exit("ERROR: Unable to detect muscle segments in "+title1+"");
								}
							//del last and first segments to use approx. "middle"
								ROIc = roiManager("count");
								if(ROIc>2){
									roiManager("select", ROIc-1);
									roiManager("delete");
								}
								ROIc = roiManager("count");
								if(ROIc>1){
									roiManager("select", ROIc-1);
									roiManager("delete");
								}
								ROIc = roiManager("count");
								while (ROIc!=1) {
									roiManager("select", 0);
									roiManager("delete");
									ROIc = roiManager("count");
								}
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("segment used for image orientation for image"+title1+"");
								}
								print("selecting segment center slice");
								selectWindow(""+endo+""+title2+"-1.tif");
								run("Duplicate...", " ");
								run("Rotate 90 Degrees Right");
								roiManager("select", 0);
								getBoundingRect(x, y, width, height);
								y=y+(height/2.8);
								run("Specify...", "width=580 height=25 x=0 y="+y+"");
								roiManager("Add");
								roiManager("select", 0);
								roiManager("delete");
								roiManager("select", 0);
								run("Duplicate...", " ");
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("center section of segment used for image orientation for image"+title1+"");
								}
			//measure x distance values on section of big (venous) vs small (anastomotic) signal to get orientation
								run("Copy");
								run("Internal Clipboard");
								selectWindow("Clipboard");
								run("Select None");
								run("Select All");
								getBoundingRect(x, y, width, height);
								allx=x;
								print("detecting anastomotic vessle");
								roiManager("reset");
								run("Select None");
								run("Enhance Contrast", "saturated=0.35");
								setAutoThreshold("Triangle dark");
								run("Convert to Mask");
								run("Analyze Particles...", "size="+PDaA+"-"+PDaB+" circularity="+PCaA+"-"+PCaB+" "+INCa+" add");
								if(roiManager("count") == 0){
									setBatchMode("show");
									print("________________");
									print("STOPPING MACRO");
									print("________________");
									print("ERROR1: Unable to detect anastomotic vessles in "+title1+"");
									exit("ERROR1: Unable to detect anastomotic vessles in "+title1+"");
								}
								roiManager("Select", 0);
								getBoundingRect(x, y, width, height);
								smallx=x;
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("detested anastomotic vessle for image"+title1+"");
								}
								roiManager("reset");
								print("detecting caudal vein plexus");
								selectWindow("Clipboard");
								run("Select None");
								run("Enhance Contrast", "saturated=0.35");
								setAutoThreshold("Triangle dark");
								run("Convert to Mask");
								run("Analyze Particles...", "size="+PDcA+"-"+PDcB+" circularity="+PCcA+"-"+PCcB+" "+INCc+" add");
								if(roiManager("count") == 0){
									setBatchMode("show");
									print("________________");
									print("STOPPING MACRO");
									print("________________");
									print("ERROR: Unable to detect caudal vein plexus region in "+title1+"");
									exit("ERROR: Unable to detect caudal vein plexus region in "+title1+"");
								}
								roiManager("Select", 0);
								getBoundingRect(x, y, width, height);
								bigx=x;
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("detected caudal vein plexus region for image"+title1+"");
								}
								while (nImages>0) {					//del single ROIs
									selectImage(nImages);
									close();
								}
								roiManager("reset");
								print("RESULT:");
			//set variable for flipping of image based on x localisation
								if(bigx>smallx){
									flip=true;
									print("image "+title1+" will be flipped");
								}
									else{
										flip=false;
										print("image "+title1+" will NOT be flipped");
									}
			//open and flip
								print("_");
								print("correcting orientation of image "+title1+" :");
								print("Re-opening image");
								path = singledirH+listH[j];
								run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
								title1= getTitle;
								title2 = File.nameWithoutExtension;
			//orienting image on horizontal axis
								print("adjusting rotation to horizontal axis");
								selectWindow(""+title1+"");
								run("Duplicate...", "duplicate");
								run("Split Channels");
								selectWindow(""+endo+""+title2+"-1.tif");
								run("Despeckle");
								run("Mean...", "radius="+BLro+"");
								run("Find Edges");
								print("detecting outline and shape orientation");
								print("thresholding method: "+TRoM+", with min "+TRoA+" and max "+TRoB+"");
								setAutoThreshold(""+TRoM+"");
								setThreshold(TRoA, TRoB);
								if(darko==true){
									setOption("BlackBackground", true);
								}
								run("Convert to Mask");
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("Threshold for horizontal orientation for image"+title1+"");
								}
								run("Analyze Particles...", "size="+PDoA+"-"+PDoB+" circularity="+PCoA+"-"+PCoB+" "+INCo+" add");
								if(roiManager("count") == 0){
									setBatchMode("show");
									print("________________");
									print("STOPPING MACRO");
									print("________________");
									print("ERROR2: Unable to detect fish outline in "+title1+"");
									exit("ERROR2: Unable to detect fish outline in "+title1+"");
								}
								roiManager("Select", 0);
								run("Fit Ellipse");				//to get Feret angle
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("ellipse for horizontal orientation for image"+title1+"");
								}
								roiManager("Add");
								roiManager("Select", 0);
								roiManager("delete");
								roiManager("Select", 0);
								run("Set Measurements...", "area feret's redirect=None decimal=4");
								run("Measure");
								List.setMeasurements;
									angle = List.getValue("FeretAngle");
								print("rotating "+angle+"°");
								selectWindow(""+title1+"");
								run("Rotate... ", "angle=3.9947 grid=1 interpolation=Bilinear stack");
								if((step==true)|(stepO==true)){
									setBatchMode("show");
									waitForUser("corrected for horizontal orientation ["+angle+"°]");
								}
								selectWindow(""+endo+""+title2+"-1.tif");
								close();
								run("Clear Results");
								roiManager("Deselect");
								roiManager("Delete");
								print("adjusting vertical orientation");
								if(flip==true){
									titleS= getTitle;
									titleS2 = File.nameWithoutExtension;
									print("flipping and saving image:"+titleS2+"");
									run("Flip Vertically", "stack");
									saveAs("tif", singledirH+titleS2+".tif");
									close();
									}
									else{
										titleS= getTitle;
										titleS2 = File.nameWithoutExtension;
										print("saving image:"+titleS2+"");
										saveAs("tif", singledirH+titleS2+".tif");
										close();
									}
								while (nImages>0) {					//del single ROIs
									selectImage(nImages);
									close();
								}
								print("_");
							}	else{
									titleS= getTitle;
									titleS2 = File.nameWithoutExtension;
									print(titleS);
									run("Brightness/Contrast...");
									run("Enhance Contrast", "saturated=0.35");
									if(batch==true){
										setBatchMode("show");
									}
									waitForUser("please adjust sample orientation (dorsal north / ventral south) via IMAGE>TRANSFORM>FLIP, then click OK");
									waitForUser("please adjust sample rotation (best horizontal alingment) via IMAGE>TRANSFORM>ROTATE, then click OK");
									print("image "+titleS+" manually oriented");
									saveAs("tif", singledirH+titleS2+".tif");
									print("image "+titleS+" saved");
										close();
								}
						print("_");
						}		
	//analyse high Mag images:
					listH = getFileList(singledirH);
					nImg=listH.length*2;
					print("analysing circulating particles :");
					print("_");
					N=0;
					for (j=0; j<listH.length; j++) {
						roiManager("reset");
						path = singledirH+listH[j];
						run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
						title1= getTitle;
						title2 = File.nameWithoutExtension;
						Nrep=N+1;
						print("IMAGE "+Nrep+" of "+nImg+"");
						print("analysing "+title1+":");
						run("Split Channels");
						if(mart==false){
							selectWindow(""+endo+""+title1+"");
							run("Select None");
							run("Duplicate...", " ");
		//adjust signal to noise ratio
							print("adjusting signal to noise ratio via FFT Bandpass filter");
							run("Bandpass Filter...", "filter_large=300 filter_small=5 suppress=None tolerance=20 autoscale saturate");
							print("FFT done");
							run("Rotate 90 Degrees Right");
							run("Duplicate...", " ");
		//detect muscle-segments and modify roi for artery (shape/move/rotate)
							print("detecting artery ROI based on muscle segments (fli) :");
							print("thresholding method: "+TRseM+", with min "+TRseA+" and max "+TRseB+"");
							run("Mean...", "radius="+BLrse+"");
							setAutoThreshold(""+TRseM+"");
							setThreshold(TRseA, TRseB);
							if(darkse==true){
								setOption("BlackBackground", true);
							}
							run("Convert to Mask");
							run("Invert");
							run("Fill Holes");
							if((step==true)|(stepAR==true)){
								setBatchMode("show");
								waitForUser("Threshold for segment detection for image"+title1+"");
							}
							run("Analyze Particles...", "size="+PDseA+"-"+PDseB+" circularity="+PCseA+"-"+PCseB+" "+INCse+" add");
							if(roiManager("count") == 0){
								setBatchMode("show");
								print("________________");
								print("STOPPING MACRO");
								print("________________");
								print("ERROR3: Unable to detect muscle segments in "+title1+"");
								exit("ERROR3: Unable to detect muscle segments in "+title1+"");
							}
		//delete first and last as inconsistent
							roiManager("Select", 0);
							roiManager("delete");
							delROI =roiManager("count");
							if (delROI>1) {
								roiManager("select", delROI-1);
								roiManager("delete");
							}
							if((step==true)|(stepAR==true)){
								setBatchMode("show");
								waitForUser("segments for artery ROI generation for image"+title1+"");
							}
							nROI = parseInt(roiManager("count"));
							print("generating artery ROI");			
		//generate artery "boxes"
							for (i=0; i<nROI; i++) {
								roiManager("Select", i);
								getBoundingRect(x, y, width, height);
								width=ARTw;
								height=80;//56
								x=x-ARTpx;
								y=y+12;
								run("Specify...", "width="+width+" height="+height+" x="+x+" y="+y+"");
								run("Rotate...", "  angle="+ARTg+"");
								roiManager("Add");
							}	
		//delete segment rois
							nROI =roiManager("count");
							for (i=0; i<nROI; i++) {
								roiManager("Select", 0);
								getBoundingRect(x, y, width, height);
								if(width>30){
									roiManager("Select", 0);
									roiManager("delete");
								}
							}
							roiManager("Select", newArray());
							run("Select All");
							roiManager("Combine");
							roiManager("Add");
							roiManager("deselect");
							ROIc = roiManager("count");
							while (ROIc!=1) {
								roiManager("select", 0);
								roiManager("delete");
								ROIc = roiManager("count");
							}
		//delete "non artery signals"
							print("specifying artery ROI");
							selectWindow(""+par+""+title1+"");
							run("Select All");
							run("Rotate 90 Degrees Right");
							run("Select None");
							run("Duplicate...", " ");
							roiManager("Show None");
							roiManager("Show All");
							roiManager("select", 0);
							run("Make Inverse");
							setBackgroundColor(0, 0, 0);
							if(batch == false){
								wait(50);
							}
							run("Clear", "slice");
							run("Select None");
							if((step==true)|(stepAR==true)){
								setBatchMode("show");
								waitForUser("approximate artery ROI for image"+title1+"");
							}
		//specifying artery ROI:
							if(batch==true){
							selectWindow(""+endo+""+title1+"");
							run("Select None");
							run("Duplicate...", " ");
		//adjust signal to noise ratio 2
							print("adjusting signal to noise ratio via FFT Bandpass filter");
							print("FFT done");
							run("Bandpass Filter...", "filter_large=300 filter_small=5 suppress=None tolerance=20 autoscale saturate");
							run("Rotate 90 Degrees Right");
							run("Duplicate...", " ");
		//detect muscle-segments and modify roi for artery (shape by deletion of undesired signald based on muscle segment ROIS and expansion/contraction) 
							print("redefining artery ROI");
							print("thresholding method: "+TRarM+", with min "+TRarA+" and max "+TRarB+"");
							run("Mean...", "radius="+BLrar+"");
							setAutoThreshold(""+TRarM+"");
							setThreshold(TRarA, TRarB);
							if(darkar==true){
								setOption("BlackBackground", true);
							}
							run("Convert to Mask");
							run("Invert");
							run("Fill Holes");
							}
								else{
									selectWindow(""+endo+""+title2+"-2.tif");
								}
							roiManager("reset");
							if((step==true)|(stepAR==true)){
								setBatchMode("show");
								waitForUser("teshold for artery ROI redefinition 1 for image"+title1+"");
							}
							run("Analyze Particles...", "size="+PDarA+"-"+PDarB+" circularity="+PCarA+"-"+PCarB+" "+INCar+" add");
							if(roiManager("count") == 0){
								setBatchMode("show");
								print("________________");
								print("STOPPING MACRO");
								print("________________");
								print("ERROR4: Unable to detect muscle segments in "+title1+"");
								exit("ERROR4: Unable to detect muscle segments in "+title1+"");
							}	
							nROI = parseInt(roiManager("count"));
							for (i=0; i<nROI; i++) {
								roiManager("Select", i);
								run("Enlarge...", "enlarge="+ENLar+"");
								roiManager("Add");
							}		
							roiManager("Select", newArray());
							run("Select All");
							roiManager("Combine");
							roiManager("Add");
							roiManager("deselect");
							ROIc = roiManager("count");
							while (ROIc!=1) {
								roiManager("select", 0);
								roiManager("delete");
								ROIc = roiManager("count");
							}
							roiManager("deselect");
							if(batch==true){
								selectWindow(""+par+""+title1+"");
								run("Select None");
								run("Duplicate...", " ");
								wait(10);

							}	else{
									selectWindow(""+par+""+title2+"-1.tif");
									run("Select None");
									run("Duplicate...", " ");
							}
							roiManager("Select", 0);
							run("Make Inverse");
							setBackgroundColor(0, 0, 0);
							if(batch == false){
								wait(50);
							}
							run("Clear", "slice");
							if((step==true)|(stepAR==true)){
								setBatchMode("show");
								waitForUser("redefined artery ROI 1 for image"+title1+"");
							}
							selectWindow(""+endo+""+title2+"-1.tif");
							run("Select None");
							run("Duplicate...", " ");
							run("Despeckle");
							run("Sharpen");
							run("Sharpen");
							setAutoThreshold("Yen dark");
							setThreshold(9252, 65535);
							run("Convert to Mask");
														
							roiManager("Select", 0);
							run("Clear", "slice");
							roiManager("Deselect");
							roiManager("Delete");
							run("Select None");
							run("Invert");
							run("Watershed");
							run("Analyze Particles...", "size=1500.00-10000.00 circularity=0.01-1.00 include add");
							roiManager("Combine");
							roiManager("Add");
							ROIc = roiManager("count");
							roiManager("Select", ROIc-1);
							run("Enlarge...", "enlarge=8");
							roiManager("Add");
							while (ROIc!=1) {
								roiManager("select", 0);
								roiManager("delete");
								ROIc = roiManager("count");
							}
							selectWindow(""+par+""+title2+"-1.tif");
							run("Select None");
							roiManager("select", 0);
							run("Clear", "slice");
							roiManager("reset")
		//delete anastomotic regions + accumulations
							print("deleting anastomotic regions + accumulations in artery ROI");
							print("thresholding method: "+TRanM+", with min "+TRanA+" and max "+TRanB+"");
							selectWindow(""+par+""+title2+"-1.tif");
							run("Select None");
							run("Duplicate...", " ");
							setAutoThreshold(""+TRanM+"");
							setThreshold(TRanA, TRanB);
							if(darkan==true){
								setOption("BlackBackground", true);
							}
							run("Convert to Mask");
							if((step==true)|(stepARR==true)){
								setBatchMode("show");
								waitForUser("teshold for artery ROI redefinition 2 for image"+title1+"");
							}
							run("Analyze Particles...", "size="+PDanA+"-"+PDanB+" circularity="+PCanA+"-"+PCanB+" "+INCan+" add");
							ROIc = roiManager("count");
							if(ROIc>0){
								noACC=false;
								for (i=0; i<ROIc; i++) {
									roiManager("Select", i);
									run("Enlarge...", "enlarge="+ENLan+"");
									roiManager("Add");;
									roiManager("Select", newArray());
									run("Select All");
									roiManager("Combine");
									roiManager("Add");
									roiManager("deselect");
								}
								while (ROIc!=1) {
									roiManager("select", 0);
									roiManager("delete");
									ROIc = roiManager("count");
								}
							}
								else{
									noACC=true;
									print("IMAGE "+title1+": no accumulations in artery ROI detected");
								}
							selectWindow(""+par+""+title1+"");
							run("Select None");
							run("Duplicate...", " ");
							if(LUT==true){
								run("Duplicate...", " ");
								run("8-bit");
								run(C2);
							}
							setMinAndMax(BCpA, BCpB);
							if(noACC==false){
								roiManager("select", 0);
							}
								else{
									run("Rotate 90 Degrees Left");
									setColor("white");
									setFont("SansSerif" , 16, "antiliased");
									drawString("no accumulations in artery ROI detected", 100, 100);
									run("Flatten");
									run("Rotate 90 Degrees Right");
								}
							if((step==true)|(stepARR==true)){
								setBatchMode("show");
								waitForUser("excluded accumulations for image"+title1+"");
							}
							if(batch == false){
								wait(50);
							}
								else{
									wait(10);
								}
							run("Flatten");
							setMinAndMax(6, 255);
							if(QCex == true){
								print("QC: saving excluded ROI / particles");
								run("Rotate 90 Degrees Left");
								saveAs("Gif", QCdir+title2+"_02_exclusion.gif");
							}
							if(batch==false){
							close();
							}
							selectWindow(""+par+""+title2+"-1.tif");//-2
							if(batch==true){
								wait(10);
							}
							run("Select None");
							run("Duplicate...", " ");
							run("Enhance Contrast", "saturated=0.35");
							if(noACC==false){
								roiManager("Select", 0);
								setBackgroundColor(0, 0, 0);
								if(batch == false){
									wait(50);
								}
								run("Clear", "slice");
								roiManager("Deselect");
								roiManager("Delete");
							}
							roiManager("Show None");
							print("dectecting refined artery ROI");
							print("thresholding method: "+TRafM+", with min "+TRafA+" and max "+TRafB+"");
							setOption("BlackBackground", true);
							setAutoThreshold(""+TRafM+"");
							setThreshold(TRafA, TRafB);
							if(darkaf==true){
								setOption("BlackBackground", true);
							}
							run("Convert to Mask");
							roiManager("reset");
							if((step==true)|(stepARR==true)){
								setBatchMode("show");
								waitForUser("threshold for final artery ROI for image"+title1+"");
							}
							run("Analyze Particles...", "size="+PDafA+"-"+PDafB+" circularity="+PCafA+"-"+PCafB+" "+INCaf+" add");
							if(roiManager("count") == 0){
								setBatchMode("show");
								print("________________");
								print("STOPPING MACRO");
								print("________________");
								print("ERROR: Unable to generate artery ROI from "+title1+"");
								exit("ERROR: Unable to generate artery ROI from "+title1+"");
							}
						}
							else{
								print("manual selection of artery ROI ["+rep+" regions]");
//manual artery selection:
								ar=0;
								for (j=0; j<rep; j++) {
									ar=ar+1;
									roiManager("deselect");
									selectWindow(""+par+""+title1+"");
									makeRectangle(400, 400, 65, 15);			//values can be adapted due to magnification of imaging
									setBatchMode("show");
									waitForUser("drag selection to artery region "+ar+" of "+rep+"");
									getBoundingRect(xS, yS, widthS, heightS);	// control step to avoid accidental change of ROIsize during user draging
										while((widthS !=65) | (heightS != 15)){
											run("Specify...", "width=65 height=15 x="+xS+" y="+yS+"");
											waitForUser("reset changed dimensions - please check positioning of ROI "+ar+"");
											getBoundingRect(xS, yS, widthS, heightS);
										}
									roiManager("Add");
								}
//deleting accumulation from manual ROI
//make one ROI
									roiManager("Select", newArray());
									run("Select All");
									roiManager("Combine");
									roiManager("Add");
									roiManager("deselect");
									ROIc = roiManager("count");
									while (ROIc!=1) {
										roiManager("select", 0);
										roiManager("delete");
										ROIc = roiManager("count");
									}
//delete "non artery signals" from manual ROI
									print("specifying artery ROI");
									selectWindow(""+par+""+title1+"");
									run("Select All");
									run("Select None");
									run("Duplicate...", " ");
									roiManager("Show None");
									roiManager("Show All");
									roiManager("select", 0);
									run("Make Inverse");
									setBackgroundColor(0, 0, 0);
									if(batch == false){
										wait(50);
									}
									run("Clear", "slice");
									if((step==true)|(stepAR==true)){
										setBatchMode("show");
										waitForUser("approximate manual artery ROI for image"+title1+"");
									}						
//delete anastomotic regions + accumulations from manual ROI
									print("deleting anastomotic regions + accumulations in artery ROI");
									print("thresholding method: "+TRanM+", with min "+TRanA+" and max "+TRanB+"");
									selectWindow(""+par+""+title2+"-1.tif");
									run("Select None");
									run("Duplicate...", " ");
									setAutoThreshold(""+TRanM+"");
									setThreshold(TRanA, TRanB);
									if(darkan==true){
										setOption("BlackBackground", true);
									}
									run("Convert to Mask");
									if((step==true)|(stepAR==true)){
										setBatchMode("show");
										waitForUser("teshold for manual artery ROI redefinition for image"+title1+"");
									}
									run("Analyze Particles...", "size="+PDanA+"-"+PDanB+" circularity="+PCanA+"-"+PCanB+" "+INCan+" add");
									ROIc = roiManager("count");
									if(ROIc>0){
										noACC=false;
										for (i=0; i<ROIc; i++) {
											roiManager("Select", i);
											run("Enlarge...", "enlarge="+ENLan+"");
											roiManager("Add");;
											roiManager("Select", newArray());
											run("Select All");
											roiManager("Combine");
											roiManager("Add");
											roiManager("deselect");
										}
										while (ROIc!=1) {
											roiManager("select", 0);
											roiManager("delete");
											ROIc = roiManager("count");
										}
									}
										else{
											noACC=true;
											print("IMAGE "+title1+": no accumulations in manual artery ROI detected");
										}
									selectWindow(""+par+""+title1+"");
									run("Select None");
									run("Duplicate...", " ");
									if(LUT==true){
										run("Duplicate...", " ");
										run("8-bit");
										run(C2);
									}
									setMinAndMax(BCpA, BCpB);
									if(noACC==false){
										roiManager("select", 0);
									}
										else{
											setColor("white");
											setFont("SansSerif" , 16, "antiliased");
											drawString("no accumulations in manual artery ROI detected", 100, 100);
											run("Flatten");
										}
									if((step==true)|(stepARR==true)){
										setBatchMode("show");
										waitForUser("excluded accumulations for image"+title1+"");
									}
									if(batch == false){
										wait(50);
									}
										else{
											wait(10);
										}
									run("Flatten");
									setMinAndMax(6, 255);
									if(QCex == true){
										print("QC: saving excluded ROI / particles");
										saveAs("Gif", QCdir+title2+"_02_exclusion.gif");
									}
									if(batch==false){
									close();
									}
									selectWindow(""+par+""+title2+"-1.tif");
									if(batch==true){
										wait(10);
									}
									run("Select None");
									run("Duplicate...", " ");
									run("Enhance Contrast", "saturated=0.35");
									if(noACC==false){
										roiManager("Select", 0);
										setBackgroundColor(0, 0, 0);
										if(batch == false){
											wait(50);
										}
										run("Clear", "slice");
										roiManager("Deselect");
										roiManager("Delete");
									}
									roiManager("Show None");
									print("dectecting refined artery ROI");
									print("thresholding method: "+TRafM+", with min "+TRafA+" and max "+TRafB+"");
									setOption("BlackBackground", true);
									setAutoThreshold(""+TRafM+"");
									setThreshold(TRafA, TRafB);
									if(darkaf==true){
										setOption("BlackBackground", true);
									}
									run("Convert to Mask");
									roiManager("reset");
									if((step==true)|(stepARR==true)){
										setBatchMode("show");
										waitForUser("threshold for final manual artery ROI for image"+title1+"");
									}
									run("Analyze Particles...", "size="+PDafA+"-"+PDafB+" circularity="+PCafA+"-"+PCafB+" "+INCaf+" add");
									if(roiManager("count") == 0){
										setBatchMode("show");
										print("________________");
										print("STOPPING MACRO");
										print("________________");
										print("ERROR: Unable to generate artery ROI from "+title1+"");
										exit("ERROR: Unable to generate artery ROI from "+title1+"");
									}							
							}
//generate final ROI and measure:							
						roiManager("Select", newArray());
						roiManager("Combine");
						roiManager("Add");
						ROIc = roiManager("count");
						while (ROIc!=1) {
							roiManager("select", 0);
							roiManager("delete");
							ROIc = roiManager("count");
						}
						selectWindow(""+par+""+title1+"");
						run("Duplicate...", " ");
						if(LUT==true){
							run("Duplicate...", " ");
							run("8-bit");
							run(C2);
						}
						setMinAndMax(BCpA, BCpB);
						roiManager("Select", 0);
						if((step==true)|(stepARR==true)){
							setBatchMode("show");
							waitForUser("final artery ROI for image"+title1+"");
						}
						if(batch == false){
							wait(50);
						}
							else{
								wait(10);
							}
						run("Flatten");
						setMinAndMax(6, 255);
						if(QCap == true){
							print("QC: saving artery ROI / particles");
							run("Rotate 90 Degrees Left");
							saveAs("Gif", QCdir+title2+"_03_artery_Overlay.gif");
						}
						if(batch==false){
						close();
						}
						if (mart==true){
							act="artery [manual]";
						}	
							else{
							act="artery [auto]";
							}
						print("measuring artery fluorescence");
						run("Set Measurements...", "area mean integrated redirect=None decimal=4");
						selectWindow(""+par+""+title1+"");
						if((step==true)|(stepAR==true)|(stepARR==true)){
							setBatchMode("show");
							waitForUser("measured region for image"+title1+"");
						}
						actimage = getTitle();
						roiManager("select",0);
						run("Measure");
					//QC: saving excluded ROI / particles
						setResult("filename", nResults-1, actimage);
						setResult("measured ROI", nResults-1, act);
						updateResults();
						roiManager("deselect");
						roiManager("delete");
						while (nImages>0) {					//del single ROIs
							selectImage(nImages);
							close();
						}
						print("_");
						N=N+1;
					}
						Nrep3=N/2;
					print("saving results from "+N+" high mag images to "+Resdir+v+"_flow.xls");
					selectWindow("Results");
					saveAs("txt", Resdir+v+"_flow.xls");
					print("_");
					run("Clear Results");
					updateResults;			
				}
					else{
						//moar methods?
					}
	//analyse low Mag images
	listL = getFileList(singledirL);
	print("detecting whole fish particle fluorescence");
	print("_");
	for (i=0; i<listL.length; i++){
		roiManager("reset");
		path = singledirL+listL[i];
		run("Bio-Formats Windowless Importer", "open=[path]autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
		title1= getTitle;
		title2 = File.nameWithoutExtension;
		Nrep2=N+1;
		print("ANALYSING IMAGE "+Nrep2+" of "+nImg+"");
		print("analysing low mag image "+title1+":");
		run("Split Channels");
		selectWindow(""+tra+""+title1+"");
		run("Duplicate...", " ");
	//detect fish outline in transmission:
		act="whole fish";
		print("detecting fish outline");
		print("thresholding method: "+WTRM+", with min "+WTRA+" and max "+WTRB+"");
		selectWindow(""+tra+""+title2+"-1.tif");
		if(WefM==true){
			run("Find Edges");
		}
		if((step==true)|(stepW==true)){
			setBatchMode("show");
			waitForUser("detected edges in whole fish image for image"+title1+"");
		}
		setAutoThreshold(""+WTRM+"");
		setThreshold(WTRA, WTRB);
		if(Wdark==true){
			setOption("BlackBackground", true);
		}
		run("Convert to Mask");
		run("Make Binary");
		if((step==true)|(stepW==true)){
			setBatchMode("show");
			waitForUser("threshold for whole fish detection for image"+title1+"");
		}
		run("Analyze Particles...", "size="+WPDA+"-"+WPDB+" circularity="+WPCA+"-"+WPCB+" "+WINC+" add");
		if(roiManager("count") == 0){
			setBatchMode("show");
			print("________________");
			print("STOPPING MACRO");
			print("________________");
			print("ERROR: Unable to detect fish outline in "+title1+"");
			exit("ERROR: Unable to detect fish outline in "+title1+"");
		}
		roiManager("Select", 0);
		if((step==true)|(stepW==true)){
			setBatchMode("show");
			waitForUser("whole fish ROI for image"+title1+"");
		}
		run("To Bounding Box");
		roiManager("Add");
		run("Make rectangular selection rounded", "radius=60");
		roiManager("Add");
		selectWindow(""+par+""+title1+"");
		run("Duplicate...", " ");
		ROIc = roiManager("count");
		while (ROIc!=1) {
			roiManager("select", 0);
			roiManager("delete");
			ROIc = roiManager("count");
		}
		if(LUT==true){
			run("Duplicate...", " ");
			run("8-bit");
			run(C2);
		}
		setMinAndMax(BCwA, BCwB);
		roiManager("Select", 0);
		if((step==true)|(stepW==true)){
			setBatchMode("show");
			waitForUser("final selection for whole fish for image"+title1+"");
		}
		if(batch == false){
			wait(50);
		}
		run("Flatten");
		if(QCf == true){
			print("QC: saving fish outline");
			saveAs("Gif", QCdir+title2+"_01_Whole.gif");
		}
		if(batch==false){
		close();
		}
		print("measuring whole fish particle signals");
		run("Set Measurements...", "area mean integrated redirect=None decimal=4");
		selectWindow(""+par+""+title1+"");
		actimage = getTitle();
		roiManager("select",0);
		run("Make Inverse");
		run("Set Measurements...", "area mean integrated redirect=None decimal=4");
		run("Measure");
		mean = getResult("Mean");
		roiManager("deselect");
		run("Select All");
		run("Subtract...", "value=" +mean);
		run("Select None");
		index1 = index2 = nResults-1;
		IJ.deleteRows(index1, index2)
		updateResults;
		roiManager("select",0);
		run("Make Inverse");
		run("Set Measurements...", "area mean integrated redirect=None decimal=4");
		run("Measure");
		setResult("filename", nResults-1, actimage);
		setResult("measured ROI", nResults-1, act);
		updateResults();
		roiManager("deselect");
		roiManager("delete");
		print("_");
		while (nImages>0) {					//del single ROIs
			selectImage(nImages);
			close();
		}
		N=N+1;
		Nrep3=N/2;
	}
	print("_");
	print("saving results from "+Nrep3+" whole fish images to "+Resdir+v+"_Whole.xls");
	print("_");
	selectWindow("Results");
	saveAs("txt", Resdir+v+"_Whole.xls");
	//cleaning up
	run("Clear Results");
	updateResults;
	if(del == true) {
		list = getFileList(singledirH);
		for (i=0; i<list.length; i++)
			ok = File.delete(singledirH+list[i]);
			ok = File.delete(singledirH);
		if(File.exists(singledirH))
			 exit("Unable to delete directory"+singledirH+"");
		else
			print("High Mag directory and files successfully deleted");
		list = getFileList(singledirL);
		for(i=0; i<list.length; i++)
			ok = File.delete(singledirL+list[i]);
			ok = File.delete(singledirL);
		if(File.exists(singledirL))
			  exit("Unable to delete directory"+singledirL+"");
			else
			print("Low Mag directory and files successfully deleted");
	}
	if(File.exists(CACHE)){
		list = getFileList(CACHE);
			for (i=0; i<list.length; i++)
				ok = File.delete(CACHE+list[i]);
				ok = File.delete(CACHE);
			if(File.exists(CACHE))
				 exit("Unable to delete directory"+CACHE+"");
	}
	print(""+N+" Images analysed");
	if (batch == true)
		setBatchMode(false);
	print("see output data in Destination Folder: "+dir2+"");
	print("_");
	getDateAndTime(year, month, week, day, hour, min, sec, msec);
	print("Finished analysis of "+N+" Images at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
	selectWindow("Log");
	saveAs("Text", ""+dir2+"/log_analysis_"+day+"-"+month+"-"+year+"_"+hour+"h"+min+"min.txt");
	showMessage("Report", ""+N+" Images analysed - see output data in Destination Folder: "+dir2+"");
	N=0;
}
//JW_04.04.19

//Prefixes:
// e_ = Entity
// i_ = integer
// a_ = array

//Get the Entity values from the map.
e_commands <- EntityGroup[0];
e_maker_12x12 <- EntityGroup[1];
e_maker_15x15 <- EntityGroup[2];
e_maker_18x18 <- EntityGroup[3];
e_maker_21x21 <- EntityGroup[4];
e_maker_24x24 <- EntityGroup[5];
e_maker_27x27 <- EntityGroup[6];
e_maker_30x30 <- EntityGroup[7];
e_maker_37x37 <- EntityGroup[8];
e_shots <- EntityGroup[9];

//Array which is used to spawn the target, it has all sizes in it
//Size = 		0			1				2				3			4				5				6			7
a_maker <- [e_maker_12x12, e_maker_15x15, e_maker_18x18, e_maker_21x21, e_maker_24x24, e_maker_27x27, e_maker_30x30, e_maker_37x37];

a_targets <- [0,0,0,0,0,0,0,0];

//target size that should be spawned
i_size <- 3;

//Creates the time variables, which are used to find the time between the creation and the target been hit
i_starttime <- Time();
i_breaktime <- Time();

//Training time variables
i_time_racc <- Time();
i_racc_total_time <-0.00;
i_time_recoil <- Time();
i_recoil_total_time <- 0.00;

//Array that stores the average time between all shoots separating by target size
a_times <- [];
a_recoil <- [];

//average time of the last 10 shoots.
i_avgtime <- 0.000;

//Max and Min values of X and Y for spawning the targets
i_x_max <- 100;
i_x_min <- -100;
i_y_max <- 100;
i_y_min <- 60;

//hits and misses variables
i_misses <- 0;
i_hits <- 0;

//activate/deactivate acc training
i_acc_training <- 0;
i_acc_miss <- 0;

//menu variable
i_has_weapon <- 0

//Recoil training variables//
i_head_shots <- 0;
i_chest_shots <- 0;
i_stomach_shots <- 0;
i_legs_shots <- 0;
i_miss_shots <- 0;
i_allowed_shots <- 5;

//Results variables
i_avgtime_total_fading <- 0.000;
i_avgtime_total <- 0.000;
i_total_targets <- 0;
i_total_targets_fading <-0;
i_initial_spray <- 0;
i_recoil_bullet <- 0;
i_fading_spray <- 0;

//training variable
i_fading <- 0;
i_coutdown_to_fading <- 5;

/*Function called when a target is broken in the map.*/
function broke()
{

	/*Verifies if the fading is enable and which Total targets variable should be added one.*/
	if(i_fading == 0)
	{
		i_total_targets+=1;
	
	}
	else{
		i_total_targets_fading+=1;
		
	}

	/*Set the variable i_breaktime with the current time.*/
	i_breaktime <- Time();

	/*creates the variable avgtime and set it to the time between the creation and destruction of the target.*/
	local avgtime = i_breaktime - i_starttime;

	/*insert avgtime in the array of reaction times.*/
	a_times.insert(0,avgtime);

	/*Reset the i_avgtime variable, uses 0.000 to indicates to the script that this variable is a float.*/
    i_avgtime = 0.000;


	/*get the average reaction time for all the value in the reaction time array.*/
	foreach(val in a_times)
	{
		i_avgtime+=val;
	}
	i_avgtime/=a_times.len();

	/* If the array has 10 times means that the iteration has been complete and start the 
	calculation to verify the next iteration target size and the feedback to give to the */
	if(a_times.len() == 10)
	{
		/*Reduce the variable responsable for defining the number o iterations without fading*/
		i_coutdown_to_fading = i_coutdown_to_fading - 1;

		/*If it`s time to enable fading, i_avgtime_total receives the value of all iterations until the moment, 
		resets the i_avgtime_total_fading varible, enable fading and say to the user that fading has been enabled.*/
		if(i_coutdown_to_fading == 0) 
		{
			i_avgtime_total = i_avgtime_total_fading;
			i_avgtime_total_fading = 0;
			i_fading = 1;
			ScriptPrintMessageCenterAll("Fading has been enabled.")
		}
		
		/*(i_avgtime + i_misses * 0.1) is equal to the average reaction time of the iteration plus 0.1 seconds for each miss shoot in the iteration.*/

		/*if is the first time i_avgtime_total_fading is being populated, it just receives the value of (i_avgtime + i_misses * 0.1).
		Otherwise, it receives it value plus (i_avgtime + i_misses * 0.1)*/
		if(i_avgtime_total_fading == 0) i_avgtime_total_fading = (i_avgtime + i_misses * 0.1);
		else i_avgtime_total_fading = (i_avgtime_total_fading + (i_avgtime + i_misses * 0.1)) / 2;

		/*If fading is enable, calculate the size of the next iteration target*/
		if(i_fading == 1)
		{	
			/*Increment the current target size, this is used to calculate the final skill level of the user*/
			a_targets[i_size]+=1;

			/*Verifies if the iteration performance is better than 0.7, if it is, reduce the size to the next iteration,
			otherwise, increase the size.*/
			if((i_avgtime + i_misses * 0.1) < 0.7)
			{
				if(i_size > 0)
					i_size = i_size - 1;
			}
			else
			{
				if((i_avgtime + i_misses * 0.1) < 7)
					i_size = i_size + 1;
			}
		}

		/*Shows to the user it's average reaction time of the current iteration and it'`'s precision.*/
		ScriptPrintMessageChatAll("You average reaction time is " + i_avgtime + " ms.")
		ScriptPrintMessageChatAll("Your precision is " + (1000 / (10 + i_misses)) + "%.");
		//Resets the array with the reaction times and the variable with the number of miss shots.
		a_times.clear();
		i_misses = 0;
	}

	//Calls the command r_cleardecals to clear all decals in the map.
	EntFireByHandle(e_commands, "Command", "r_cleardecals", 0.1, null, null);

	//calculates the total time training, which is equal to the time trained 
	//plus the time to destroy the last target plus 0.5 because this is the time between the targets.
	i_racc_total_time = i_racc_total_time + (avgtime + 0.5);
}

//Function called when the Start or Stop buttons of the reflex & precision training is triggered.
//1 - start; 0 - stop
function acc_training(x)
{
	//If the training is not running and the parameter is 1.
	if(i_acc_training == 0 && x == 1){
		// Start the training, clear the average reaction time variable, start the training timer, 
		//set fading to 0 and the number of iteration without fading to 5.
		i_acc_training = x;
		a_times.clear();
		i_time_racc = Time();
		i_fading <- 0;
		i_coutdown_to_fading <- 5;
	}
	//If the parameter is 0.
	else if(x == 0)
	{	
		//stop the training and send the time trained to the user.
		i_acc_training = 0;
		ScriptPrintMessageCenterAll("Well done! You've trained reflex & precision for " + i_racc_total_time/60 + "  minutes!");
	}

}

//Function used to create a new target.
function create()
{
	//If the traning is enabled.
	if(i_acc_training == 1)
	{
		//Set the target angle to original.
		local v1 = Vector(0, 0, 0);
		//Generates the new target positions based on random numbers.
		local v0 = Vector(RandomInt(i_x_min,i_x_max), -127.5, RandomInt(i_y_min,i_y_max));
		//Spawn the target with the size i_size in the angle v1 in the position v0.
		a_maker[i_size].SpawnEntityAtLocation(v0,v1);

		//start the target timer.
		i_starttime <- Time();
	}
}

//incremental function.
function acc_miss(){
	i_misses = i_misses + 1;
}
//incremental function.
function head_shots(){
	i_head_shots = i_head_shots + 1;
}
//incremental function.
function chest_shots(){
	i_chest_shots = i_chest_shots + 1;
}
//incremental function.
function stomach_shots(){
	i_stomach_shots = i_stomach_shots + 1;
}
//incremental function.
function legs_shots(){
	i_legs_shots = i_legs_shots + 1;
}
//incremental function.
function miss_shots(){
	i_miss_shots = i_miss_shots + 1;
}

//Function used to run the Recoil training.
function recoil(state)
{
	//if the parameter is 1, start the recoil training.
	if(state == 1)
	{
		//disable fading, set the shots counter to 30, enable the timer and clear the spray hits array.
		i_fading = 0;
		EntFireByHandle(e_shots, "SetHitMax", "30", 0.0, null, null);
		i_time_recoil = Time();
		a_recoil.clear();
	}

	//if the parameter is 3, stop the training and ask for a last spray to verify if the player has increased it's recoil skills.
	if(state == 3)
	{
		//asks for the user to do a last spray, set the shots counter to 30 and set fading to 3. 
		if(i_fading != 3) ScriptPrintMessageCenterAll("Thanks for training here, please do one last spray to see if you have improved.");
		EntFireByHandle(e_shots, "SetHitMax", "30", 0.0, null, null);
		i_fading = 3;
	}

	if(state == 2)
	{
		//create the variables with the hit shots and the total shots.
		local total_hit = i_head_shots + i_chest_shots + i_stomach_shots + i_legs_shots;
		local total_shots = i_miss_shots + i_head_shots + i_chest_shots + i_stomach_shots + i_legs_shots;

		//if the user has shot, verifies it performance, give the feedback and calculate the next iteration shots count.
		if(total_shots > 0)
		{
			//if the user has finished the training, populates the variable with it last recoil accuracy.
			if(i_fading == 3)
			{
				i_fading_spray = (total_hit * 100) / total_shots;
			}

			//insert in the total hit value into the recoil hits array.
			a_recoil.insert(0,total_hit);

			//If the iteration has been completed.
			if(a_recoil.len() == 5)
			{
				//creates a float variable with the average percentage of the recoil accuracy.
				local average = 0.000;

				//calculates the average recoil accuracy percentage of the iteration.
				foreach(val in a_recoil)
				{
					average+=val;
				}
				average = average / a_recoil.len();
				local average_percentage = (average * 100) / total_shots;

				//clear the recoil hits array.
				a_recoil.clear();

				//if fading isn't enabled.
				if(i_fading == 0)
				{
					//fill the variable with the average spray accuracy before the training, enable fading,
					//give the feedback to the user and set the shots limit to 5.
					i_initial_spray = average_percentage;
					i_fading  = 1;
					ScriptPrintMessageCenterAll("Fading has been enabled. You`ll start with 5 bullets allowed.")
					EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
				}

				//If fading is enable.
				else{
					//Verifies the iteration average and sum to the shots counter 1, 2 or 3 bullets to the shot counter max, depending on the user performance.
					//gives the user the feedback about the iteration.
					//Verifies if the allowed shots is less the 30 because the total number of bullets in the weapons used are 30,
					//so it can`t get above 30.
					if(average_percentage >= 100)
					{
						ScriptPrintMessageCenterAll("Your recoil accuracy with " + total_shots + " shoots is " + average_percentage + "%. Adding three bullet")
						if(i_allowed_shots < 30)
						{
							i_allowed_shots = i_allowed_shots + 3;
							EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
						}
					}
					else if(average_percentage >= 90)
					{
						ScriptPrintMessageCenterAll("Your recoil accuracy with " + total_shots + " shoots is " + average_percentage + "%. Adding two bullets")
						if(i_allowed_shots < 30)
						{
							i_allowed_shots = i_allowed_shots + 2;
							EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
						}
					}
					else if(average_percentage >= 80)
					{
						ScriptPrintMessageCenterAll("Your recoil accuracy with " + total_shots + " shoots is " + average_percentage + "%. Adding a bullet")
						if(i_allowed_shots < 30)
						{
							i_allowed_shots = i_allowed_shots + 1;
							EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
						}
					}
					//if the user has an accuracy lower than 80%, no shots are added to the next iteration.
					else ScriptPrintMessageCenterAll("Your recoil accuracy with " + total_shots + " shoots is " + average_percentage + "%. No bullets added, keep trying.")
				}
			}
		}

		//Forces the user to stop the recoil when the shots limit has been reached
		//by forcing it to get his knife and then switching back to it's first weapon.
		EntFireByHandle(e_commands, "Command", "-knife", 0, null, null);
		EntFireByHandle(e_commands, "Command", "-knife", 0.1, null, null);
		//Reset the user ammonition by switching the ammonition to infinite and the finite again.
		EntFireByHandle(e_commands, "Command", "sv_infinite_ammo 1", 0.2, null, null);
		EntFireByHandle(e_commands, "Command", "sv_infinite_ammo 2", 0.3, null, null);
		//Clear all decals in the map.
		EntFireByHandle(e_commands, "Command", "r_cleardecals", 0, null, null);	
		//Reset the shots counter.
		EntFireByHandle(e_shots, "SetValue", "0", 0.0, null, null);

		//Give to the user the feedback about the last iteration.
		ScriptPrintMessageChatAll("Last spray: ");
		ScriptPrintMessageChatAll("You hit " + total_hit + "/" + total_shots);
		ScriptPrintMessageChatAll("head shots : " + i_head_shots);
		ScriptPrintMessageChatAll("chest shots : " + i_chest_shots);
		ScriptPrintMessageChatAll("stomach shots : " + i_stomach_shots);
		ScriptPrintMessageChatAll("leg shots : " + i_legs_shots);

		//Reset the variables used to calculate the spray hit values.
		i_head_shots = 0;
		i_chest_shots = 0;
		i_stomach_shots = 0;
		i_legs_shots = 0;
		i_miss_shots = 0;

		//calculates the time the user has been training it's recoil.
		i_recoil_total_time = i_recoil_total_time + (Time() - i_time_recoil);
		i_time_recoil = Time();
	}
}


//Function used to give to the user the weapon of choice.
function weapon(weapon)
{
	//if the user doesn't have a weapon, give them the weapon he chooses.
	if (i_has_weapon == 0)
	{
		i_has_weapon = weapon;
		if(weapon == 1)	EntFireByHandle(e_commands, "Command", "give weapon_ak47", 0, null, null);
		if(weapon == 2)	EntFireByHandle(e_commands, "Command", "give weapon_m4a1", 0, null, null);
		if(weapon == 3)	EntFireByHandle(e_commands, "Command", "give weapon_sg556", 0, null, null);
		if(weapon == 4)	EntFireByHandle(e_commands, "Command", "give weapon_aug", 0, null, null);
	}
}

//Function to give to the user the feedback about the training session.
function results()
{
	local weapon;
	local size;
	local size_fading

	//Verifies which weapon the user used in the training.
	if(i_has_weapon == 1) weapon = "AK-47";
	if(i_has_weapon == 2) weapon = "M4A1";
	if(i_has_weapon == 3) weapon = "SG556";
	if(i_has_weapon == 4) weapon = "AUG";

	//Calculates the player skill multiplier based on the main target of the reflex & precision training.
	for(local x=0;x<8;x+=1)
	{
		if(size < a_targets[x]) size = x;
	}


	//Give the feedback to the user in the console.
	printl("Portugues: Obrigado por testar este mapa. Por favor, copie seu resultado e compartilhe na aba de Discussões deste mapa na oficina da steam.");
	printl("English: Thank you for testing this map. Please copy your results and share it in the discussion tab in our steam workshop page.")
	printl("*******************************************");

	//If the user used the reflex & precision training, gives it feedback.
	if(i_racc_total_time > 0)
	{
		printl("Reflex and precision training:");
		printl("	You have trained you reaction and accuracy during " + i_racc_total_time + " seconds");
		printl("	Before Fading")
		printl("		Your average reaction time is: " + i_avgtime_total_fading);
		printl("		You hit " + i_total_targets + " targets");
		printl("	With Fading")
		printl("		Your average target size with fading is: " + size + "  // 0 best - 7 worst");
		printl("		Your average reaction time is: " + i_avgtime_total_fading);
		printl("		You hit " + i_total_targets + " targets");
	}

	//If the user select and weapon and used the recoil training, gives it feedback.
	if(i_has_weapon > 0 && i_recoil_total_time > 0)
	{
		printl("Spray control training:");
		printl("	You have trained you spray control during " + i_recoil_total_time + " seconds");
		printl("	Weapon used: " + weapon);
		printl("	Initial Full spray control: " + i_initial_spray + "%");
		printl("	You can control the initial " + i_allowed_shots + " bullets");
		printl("	Your Full spray after fading is: " + i_fading_spray + "%");
	}
	printl("*******************************************");
	printl("Portugues: Obrigado por testar este mapa. Por favor, copie seu resultado e compartilhe na aba de Discussões deste mapa na oficina da steam.");
	printl("English: Thank you for testing this map. Please copy your results and share it in the discussion tab in our steam workshop page.")

	//Give the feedback to the user in the game chat.
	ScriptPrintMessageChatAll("Portugues: Obrigado por testar este mapa. Por favor, copie seu resultado e compartilhe na aba de Discussões deste mapa na oficina da steam.");
	ScriptPrintMessageChatAll("English: Thank you for testing this map. Please copy your results and share it in the discussion tab in our steam workshop page.")
	ScriptPrintMessageChatAll("*******************************************");

	//If the user used the reflex & precision training, gives it feedback.
	if(i_racc_total_time > 0)
	{
		ScriptPrintMessageChatAll("Reflex and precision training:");
		ScriptPrintMessageChatAll("	You have trained you reaction and accuracy during " + i_racc_total_time + " seconds");
		ScriptPrintMessageChatAll("	Before Fading")
		ScriptPrintMessageChatAll("		Your average reaction time is: " + i_avgtime_total);
		ScriptPrintMessageChatAll("		You hit " + i_total_targets + " targets");
		ScriptPrintMessageChatAll("	With Fading")
		ScriptPrintMessageChatAll("		Your average target size with fading is: " + size + "  // 1 best - 7 worst");
		ScriptPrintMessageChatAll("		Your average reaction time is: " + i_avgtime_total_fading);
		ScriptPrintMessageChatAll("		You hit " + i_total_targets + " targets");
	}

	//If the user select and weapon and used the recoil training, gives it feedback.
	if(i_has_weapon > 0 && i_recoil_total_time > 0)
	{
		ScriptPrintMessageChatAll("Spray control training:");
		ScriptPrintMessageChatAll("	You have trained you spray control during " + i_recoil_total_time + " seconds");
		ScriptPrintMessageChatAll("	Weapon used: " + weapon);
		ScriptPrintMessageChatAll("	Initial Full spray control: " + i_initial_spray + "%");
		ScriptPrintMessageChatAll("	You can control the initial " + i_allowed_shots + " bullets");
		ScriptPrintMessageChatAll("	Your Full spray after fading is: " + i_fading_spray + "%");
	}
	ScriptPrintMessageChatAll("*******************************************");
	ScriptPrintMessageChatAll("Portugues: Obrigado por testar este mapa. Por favor, copie seu resultado e compartilhe na aba de Discussões deste mapa na oficina da steam.");
	ScriptPrintMessageChatAll("English: Thank you for testing this map. Please copy your results and share it in the discussion tab in our steam workshop page.")
	
}
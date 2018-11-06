//Prefixes:
// e_ = Entity
// i_ = integer
// a_ = array

//Get the Entity values from the map.
e_commands <- EntityGroup[0];
e_maker_5x5 <- EntityGroup[1];
e_maker_8x8 <- EntityGroup[2];
e_maker_12x12 <- EntityGroup[3];
e_maker_15x15 <- EntityGroup[4];
e_maker_18x18 <- EntityGroup[5];
e_maker_24x24 <- EntityGroup[6];
e_maker_30x30 <- EntityGroup[7];
e_maker_37x37 <- EntityGroup[8];
e_shots <- EntityGroup[9];
e_player <-EntityGroup[10];

//Array which is used to spawn the target, it has all sizes in it
//Size = 		0			1				2				3			4				5				6			7
a_maker <- [e_maker_5x5, e_maker_8x8, e_maker_12x12, e_maker_15x15, e_maker_18x18, e_maker_24x24, e_maker_30x30, e_maker_37x37];

//target size that should be spawned
i_size <- 2;

//Creates the time variables, which are used to find the time between the creation and the target been hit
i_starttime <- Time();
i_breaktime <- Time();

//Training time variables
i_time_racc <- Time();
i_time_recoil <- Time();


//Array that stores the average time between all shoots separating by target size
a_times <- [];
a_recoil <- [];

//average time of the last 10 shoots.
i_avgtime <- 0;

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

//Recoil training variables//
i_head_shots <- 0;
i_chest_shots <- 0;
i_stomach_shots <- 0;
i_legs_shots <- 0;
i_miss_shots <- 0;
i_allowed_shots <- 5;

function broke()
{
	i_breaktime <- Time();

	local avgtime = i_breaktime - i_starttime;

    i_avgtime = 0;

	a_times.insert(0,avgtime);

	if(a_times.len() > 10)
		a_times.pop();

	foreach(val in a_times)
	{
		i_avgtime = i_avgtime + val;
	}
	
	i_avgtime = i_avgtime / a_times.len();

	print("Media de tempo para atingir o alvo ");
	print(" : ");
	printl(i_avgtime);
	
	//ScriptPrintMessageCenterAll("sua reacao foi de : " + avgtime + " ms.");

	i_hits = i_hits + 1;
	local total_shots = i_hits + i_misses;

	if(a_times.len() == 10)
	{
		i_avgtime = i_avgtime + i_misses * 0.1;
		if(i_avgtime < 0.7)
		{
			if(i_size > 0)
				i_size = i_size - 1;
		}
		else
		{
			if(i_size < 7)
				i_size = i_size + 1;
		}
		ScriptPrintMessageChatAll("Sua precisao foi de " + ((i_hits * 100) / total_shots) + "%");
		ScriptPrintMessageChatAll("Calculando novo tamanho de alvo...");
		ScriptPrintMessageChatAll("Novo tamanho calculado.");
		a_times.clear();
		i_hits = 0;
		i_misses = 0;
	}

	if((Time() - i_time_racc) > 600)
	{
		ScriptPrintMessageCenterAll("Well done! You completed the 5 minutes reflex and accuracy training!");	
		i_acc_training = 0;
	}
}

function acc_training(x)
{
	i_acc_training = x;
	a_times.clear();
	i_time_racc = Time();
}

function create()
{
	if(i_acc_training == 1)
	{
		local v1 = Vector(0, 0, 0);
		local v0 = Vector(RandomInt(i_x_min,i_x_max), -127.5, RandomInt(i_y_min,i_y_max));
		
		a_maker[i_size].SpawnEntityAtLocation(v0,v1);

		i_starttime <- Time();
	}
}

function acc_miss(){
	i_misses = i_misses + 1;
}

function head_shots(){
	i_head_shots = i_head_shots + 1;
}

function chest_shots(){
	i_chest_shots = i_chest_shots + 1;
}

function stomach_shots(){
	i_stomach_shots = i_stomach_shots + 1;
}

function legs_shots(){
	i_legs_shots = i_legs_shots + 1;
}

function miss_shots(){
	i_miss_shots = i_miss_shots + 1;
}

function recoil(state)
{
	if(state == 1)
	{
		EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
		i_time_recoil = Time();
		state = 2;
		a_recoil.clear();
	}

	if(state == 2)
	{
		local total_hit = i_head_shots + i_chest_shots + i_stomach_shots + i_legs_shots;
		local total_shots = i_miss_shots + i_head_shots + i_chest_shots + i_stomach_shots + i_legs_shots;
		
		printl(total_shots);

		if(total_shots > 0)
		{
			local average = 0;

			a_recoil.insert(0,total_hit);

			if(a_recoil.len() > 5)
			{
				foreach(val in a_recoil)
				{
					average = average + val;
				}
				
				average = average / a_recoil.len();

				a_recoil.clear();
				
				local average_percentage = (average * 100) / i_allowed_shots;

				ScriptPrintMessageCenterAll("Your recoil accuracy with " + i_allowed_shots + " is " + average_percentage + "%")	

				if(average_percentage > 80)
				{
					if(i_allowed_shots < 30)
					{
						i_allowed_shots = i_allowed_shots + 1;
						EntFireByHandle(e_shots, "SetHitMax", i_allowed_shots.tostring(), 0.0, null, null);
					}
				}
			}
			
			EntFireByHandle(e_commands, "Command", "-knife", 0, null, null);
			EntFireByHandle(e_commands, "Command", "-knife", 0.1, null, null);
			EntFireByHandle(e_commands, "Command", "sv_infinite_ammo 1", 0.2, null, null);
			EntFireByHandle(e_commands, "Command", "sv_infinite_ammo 2", 0.3, null, null);
			EntFireByHandle(e_commands, "Command", "r_cleardecals", 0, null, null);	
			EntFireByHandle(e_shots, "SetValue", "0", 0.0, null, null);

			ScriptPrintMessageChatAll("Seu resultado: ");
			ScriptPrintMessageChatAll("Você acertou " + total_hit + "/" + total_shots);
			ScriptPrintMessageChatAll("Tiros na cabeça : " + i_head_shots);
			ScriptPrintMessageChatAll("Tiros no peito : " + i_chest_shots);
			ScriptPrintMessageChatAll("Tiros no estomago : " + i_stomach_shots);
			ScriptPrintMessageChatAll("Tiros nas pernas : " + i_legs_shots);
		}

		i_head_shots = 0;
		i_chest_shots = 0;
		i_stomach_shots = 0;
		i_legs_shots = 0;
		i_miss_shots = 0;

		if((Time() - i_time_recoil) > 600)
		{
			ScriptPrintMessageCenterAll("Well done! You completed the 5 minutes recoil training!");	
		}
	}
}
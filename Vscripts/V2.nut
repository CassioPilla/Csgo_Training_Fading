//Prefixes:
// e_ = Entity
// i_ = integer
// a_ = array
// t = table

//Get the Entity values from the map.
e_Target <- EntityGroup[0];
e_maker_5x5 <- EntityGroup[1];
e_maker_8x8 <- EntityGroup[2];
e_maker_12x12 <- EntityGroup[3];
e_maker_15x15 <- EntityGroup[4];
e_maker_18x18 <- EntityGroup[5];

//Array which is used to spawn the target, it has all sizes in it
//Size = 		0			1				2				3			4
a_maker <- [e_maker_5x5, e_maker_8x8, e_maker_12x12, e_maker_15x15, e_maker_18x18];

//Variable with will be used to select with target size should be spawned
i_size <- 2;

//Creates the time variables, which are used to find the time between the creation and the target been hit
i_starttime <- Time();
i_breaktime <- Time();

//Array that stores the average time between all shoots separating by target size
a_times <- [];

//Store the average time of the last 10 shoots.
i_avgtime <- 0;

//Max and Min values of X and Y for spawning the targets
i_x_max <- 100;
i_x_min <- -100;
i_y_max <- 140;
i_y_min <- 60;

function broke()
{
	i_breaktime <- Time();

	local avgtime = i_breaktime - i_starttime;

	a_times.insert(0,avgtime);

	if(a_times.len() > 10)
		a_times.pop();

	foreach(val in a_times)
	{
		i_avgtime = i_avgtime + val;
	}
	
	i_avgtime = i_avgtime / a_times.len();

	print("Media de tempo para atingir o alvo ");
	print(a_maker[i_size]);
	print(" : ");
	printl(i_avgtime);
	i_avgtime = 0;

	if(a_times.len() == 10)
	{
		if(i_avgtime < 1)
		{
			if(i_size > 0)
				i_size = i_size - 1;
			else
				printl("Voce ja esta no menor alvo possivel");
		}
		else
		{
			if(i_size < 4)
				i_size = i_size + 1;
			else
				printl("Voce ja esta no maior alvo possivel");
		}
		a_times.clear();
		printl("Novo tamanho de Target")
	}
}


function create()
{
	local v1 = Vector(0, 0, 0);
	local v0 = Vector(RandomInt(i_x_min,i_x_max), -127.5, RandomInt(i_y_min,i_y_max));
	
	a_maker[i_size].SpawnEntityAtLocation(v0,v1);

	i_starttime <- Time();
}

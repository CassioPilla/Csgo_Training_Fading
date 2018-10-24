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

//Table that stores the average time between all shoots separating by target size
a_times <- [0,0,0,0,0];


i_avgtime <- 0;

//Array that is used to calculate the average of the last 10 spawn/hit times
a_avgtime <- [];
printl(a_avgtime.len());


//Max and Min values of X and Y for spawning the targets
i_x_max <- 100;
i_x_min <- -100;
i_y_max <- 140;
i_y_min <- 60;

count <- 0;
function broke()
{
	i_breaktime <- Time();

	local avgtime = i_breaktime - i_starttime;

	i_avgtime = i_avgtime + avgtime;

	printl(avgtime);

	count++;

	if(count == 5)
	{
		i_avgtime = i_avgtime / 5;

		if(i_avgtime < 1)
		{
			if(i_size > 0)
			{
				i_size = i_size - 1;
			}
			
		}
		else
		{
			if(i_size < 4)
			{
				i_size = i_size + 1;
			}
		}

		print("Media dos ultimos 5 : ");print(i_avgtime);
		i_avgtime = 0;
		count = 0;
	}

}


function create()
{
	local v1 = Vector(0, 0, 0);
	local v0 = Vector(RandomInt(i_x_min,i_x_max), -127.5, RandomInt(i_y_min,i_y_max));
	
	
	a_maker[i_size].SpawnEntityAtLocation(v0,v1);

	i_starttime <- Time();
}
/*
date: 2013/10/23
file: ass_1_close.ck
title: Variations on Close Encounters
music by John Williams
*/

//set up 2 oscilators, one to play theme quickly, one slowly
SinOsc fastOsc => Gain g =>   dac;
.7 => fastOsc.gain;

//this will be a lower volume since
TriOsc slowOsc => g;
.3 => slowOsc.gain;

//set total gain going to dac
.7 => g.gain;

//the 5 tones in frequencies that make up the theme
[293, 329, 261, 130, 196] @=> int tones[];

//define how long a whole note should last.  all other notes will be tempNoteDurations of this
1::second => dur wholeNote;

//initialize variables used in loops
1 => int noteDuration;
1 => int tempNoteDuration;
0 => int totalLoopsPlayed;

//loop for 50 seconds.  afterwards, play theme a final time
now + 50::second => time finishTime;
while(now < finishTime )
{
	//play slow loop
	for( 0 => int i; i < tones.cap(); i++ )
	{
		//cycle through tones in slow loop
		tones[i] => slowOsc.freq;

		//play a complete fast loop for every tone of slow loop
		for( 0 => int j; j < tones.cap(); j++ )
		{
			//first time through play notes in order but with random duration
			if(totalLoopsPlayed == 0)
			{
				tones[j] => fastOsc.freq;
				Math.random2(tempNoteDuration,tempNoteDuration+1) => noteDuration;
			}

			//2nd and 3rd time, play notes in sequence randomly and with random duration 
      else if(totalLoopsPlayed == 1 || totalLoopsPlayed == 2 )
			{
				tones[Math.random2(0,4)] => fastOsc.freq;
				Math.random2(tempNoteDuration,tempNoteDuration+1) => noteDuration;
			}

			//after 3rd time, play in order, but speed up even more with each iteration.  
      else if(totalLoopsPlayed > 2)
			{
				tones[j] => fastOsc.freq;
			  noteDuration++;
			}

			//fast forward in time to actually play both tones
			wholeNote/noteDuration => now;
		}
	}

	//speed up every time through the sequence
	tempNoteDuration+1 => tempNoteDuration;
	totalLoopsPlayed++;
}

//Play sequence for last time.  Separate octaves between two oscilators more
2 =>  int octaveDiff;
for( 0 => int k; k < tones.cap() ; k++ )
{
	//on last note we hold and increase octave difference
	if(k == tones.cap()-1)
	{
		4 => octaveDiff;
	  3::second => wholeNote;
	}
	tones[k]*octaveDiff => fastOsc.freq;
	tones[k]/octaveDiff => slowOsc.freq;
	wholeNote => now;
}









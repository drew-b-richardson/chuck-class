//set up two oscilators, one with panning
SinOsc s => Pan2 p  => dac;
SinOsc s2 => dac;
0.2 => s.gain;
0.1 => s2.gain;

//define step patterns of ionian and dorian scales (C-Ionian has same notes as D-dorian)
[0,2,4,5,7,9,11,12] @=> int IONIAN[];
[0,2,3,5,7,9,10,12] @=> int DORIAN[];

//constants to let us switch keys.  D is 2 tones above C
0 =>  int C;
2 =>  int D;

//song has 4 different arpeggios playing.  These show which steps of the scales, not actually midi notes.  Also, start from 1 rather than 0!
[8, 5, 3, 1] @=> int arp1[];
[7, 5, 3, 1] @=> int arp2[];
[1, 4, 6, 7] @=> int arp3[];
[8, 6, 5, 4] @=> int arp4[];

//240 beats per measure gives 4 quarter notes per second
240 => int bpm;
4.0/bpm => float minutesPerWholeNote;
8 => int durValue; //play arpeggios as eigth notes

0 => int counter; //counter for determining which note of the arpeggio we're currently on

//begin song in D-Dorian starting at octave 6.  Knowing the octave and key allows us to transpose the same arpeggio patterns to any key or octave by changing just one or two values
D =>   int key;  //try changing to Key of C!
DORIAN   @=> int scale[]; //try changing 'DORIAN' to 'IONIAN' and you get a completely different song just by changing one word!
6 => int octave; //try changing this too!
octave * 12 + key => int transpose; //this is the midi number we add to the 0 based step pattern to get the play the correct scale and key

//this forces loops to stop after 30 seconds exactly
now + 30::second => time finishTime;

//repeat first section of song twice
for(0 => int j; j < 2; j++)
{
  //play first arppegio 4 times in first oscillator while second plays root of dorian scale
  for(0 => counter; counter < 4; counter++)
  {
    //second oscillator plays root of dorian scale
    Math.mtof(scale[0] + transpose)=> s2.freq;
    for(0  => int i; i < arp1.cap(); i++)
    {
      //pan arpeggio across left and right every 2 seconds via a sine wave
      Math.sin(now/2::second*2*pi) => p.pan;
      //find transposed midi note for step pattern of arpeggio.  Need the -1 because we're defining arps as 1 based rather than 0 based!
      scale[arp1[i] -1] + transpose => int midiNote;
      //convert to Hz and set frequency
      Math.mtof(midiNote) => s.freq;
      //play as 8th notes
      minutesPerWholeNote::minute/durValue => now;
    }
  }

  //play second arppegio 4 times
  for(0 => counter; counter < 4; counter++)
  {
    //second oscillator plays 2nd of dorian scale
    Math.mtof(scale[1] + transpose) => s2.freq;
    for(0  => int i; i < arp2.cap(); i++)
    {
      Math.sin(now/2::second*2*pi) => p.pan;
      scale[arp2[i] -1] + transpose => int midiNote;
      Math.mtof(midiNote) => s.freq;
      minutesPerWholeNote::minute/durValue => now;
    }
  }
}

//switch to C IONIAN - same notes as D Dorian, but different root
C =>   key;
IONIAN   @=> scale;
octave * 12 + key => transpose;

//repeat second section of song twice
for(0 => int j; j < 2; j++)
{
  for(0 => int k; k < 4; k++)
  {
    //second oscillator plays 3rd of ionian scale
    Math.mtof(scale[4] + transpose) => s2.freq;
    for(0  => int i; i < arp1.cap(); i++)
    {
      //this time, rather than sweeping the pan, we randomly pick all left, all right, or center for each note of the arpeggio
      Math.random2(-1, 1) => p.pan;
      scale[arp1[i] -1] + transpose => int midiNote;
      Math.mtof(midiNote) => s.freq;
      minutesPerWholeNote::minute/durValue => now;
    }
  }

  for(0 => int k; k < 4; k++)
  {
    //second oscillator plays 3rd of ionian scale
    Math.mtof(scale[3] + transpose) => s2.freq;
    for(0  => int i; i < arp1.cap(); i++)
    {
      Math.random2(-1, 1) => p.pan;
      scale[arp4[i] -1] + transpose => int midiNote;
      Math.mtof(midiNote) => s.freq;
      minutesPerWholeNote::minute/durValue => now;
    }
  }
}


//switch back to D Dorian for ending
D =>   key;
DORIAN   @=> scale;
octave * 12 + key => transpose;

0 => int numTimesThrough;
//second osc playes root of d doriant
Math.mtof(scale[0] + transpose) => s2.freq;
while(now < finishTime)
{

  for(0  => int i; i < arp2.cap(); i++)
  {

    //back to sweeping pan, but once a second
    Math.sin(now/1::second*2*pi) => p.pan;
    scale[arp2[i] -1] + transpose => int midiNote;
    Math.mtof(midiNote) => s.freq;
    minutesPerWholeNote::minute/durValue => now;
    //the first two times we repeat, we slow down
    if(numTimesThrough < 2)
      durValue - (durValue/2) => durValue;
    //the next times we speed up and change the arpeggio to use arpeggio number 3
    else
    {
      durValue++;
      arp3 @=> arp2;
    }
  }
  numTimesThrough++;

}


[0,2,4,5,7,9,11,12] @=> int IONIAN[];
[0,2,3,5,7,9,10,12] @=> int DORIAN[];
0 =>  int C;
2 =>  int D;
5 => int octave;

[8, 5, 3, 1] @=> int rainNotes[];
90 => int bpm;
4.0/bpm => float minutesPerWholeNote;

D =>   int key;
DORIAN   @=> int scale[];
octave * 12 + key => int transpose;

SinOsc s => Pan2 p => dac;
0.2 => s.gain;

while(true)
{
  for(0  => int i; i < rainNotes.cap(); i++)
  {
    scale[rainNotes[i] -1] + transpose => int midiNote;
    <<< midiNote >>>;
    Math.mtof(midiNote) => s.freq;
    minutesPerWholeNote::minute/16 => now;
  }
}

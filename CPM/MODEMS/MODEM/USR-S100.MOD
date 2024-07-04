
Date: Sunday, 1 April 1984  17:27-MST
From: hplabs!tektronix!teklds!hercules!glennw at Ucb-Vax.ARPA
To:   info-micro at Brl-Aos.ARPA
Re:   USR S-100 modem

Message to net.micro from MEAD@USC-ECLB.ARPA:

>Well, I finally got fed up with its dumb power-up off-hook mode. I
>keep forgetting to run the modem program to clear things. So, avid
>warranty voider that I am, I made a mod to the pcb so that it comes
>up on-hook, yet retains program control of off-hook. Just requires
>two little wires, and a cut diode lead. Seems to be working fine.
>Oh, it will also require changing the sense of the DTR bit, to normal!
>I will give details to interested parties....so much for logic in design,
>must be a Detroit car engineer.
-------

We (Widener Consulting) have been distributing USR modems over a year.  
We encountered the DTR problem with our first S100's, and now ship 
all of them with the mod for normal DTR operation.  The mod is

1. Remove D17 (disables separate relay control)
2. Cut the trace from U3 pin 32 to ground (3/8" above U7-1 on back side).
3. Connect the DTR~ pin (U22-24) to U3-32 (pin 32 is modem disable).
   Run a wire from the U22 side of D17 to the cut trace by U7.

Simple, but USR hasn't done it, even though I told them to a long time 
ago.  Warranty is no problem (if you get it through us, since USR knows
that we are doing the mod).

				Glenn Widener
				Widener Consulting
				2835 NE Brogden
				Hillsboro, OR 97124
				503-648-0363

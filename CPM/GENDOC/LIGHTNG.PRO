Date: Wednesday, 31 July 1985
From: Howard Hull
Re:   Lightning Protection

Protecting one building or tower from lightning is fairly straightforward:

1. First order protection -

On the tallest object associated with your structure, mount an
extended umbrella-like fixture a few meters in diameter, with numerous
sharp points along the periphery and across the crown, spaced about 1
meter apart.  (You can make the thing from re-bar and heavy duty
chicken wire unless you have high winds like we have around here.)
Use a large diameter conductor (1 to 2 cm.) to connect the umbrella
points together at the center and thence down to a suitable ground
stake located at a place where soil moisture is prevalent, but more
importantly, try to make the conductor run in a straight line with
*no* sharp corners; use a minimum radius of 1.5 meters on any bends in
the ground wire.  Keep this wire at least 2 meters from any power or
communications conduit at all places along its route.  

Theory:

The multitude of points will emit a trickle corona continuously,
resulting in a space charge of ionized air within 20 meters of the
umbrella.  The space charge will terminate the cloud-to-ground
electric field across a broad hemisphere and will reduce the local
field gradient to a value below that needed to form "leaders".  The
umbrella will likely not ever be hit by lightning; however, the
conductor gauge is set to minimize the damage inherent in such a
strike.  (A strike, if it occurs, will likely be a secondary,
(resulting from the shift in electrostatic field just after a strike)
to another object within a fraction of a km.)  This approach, you
should note, puts additional stress on your neighbors (they will see a
slight rise in their hit statistics) as it only postpones the
discharge until the cloud has moved past your installation.  The
ground conductor is spaced from other conduits so that the
Electromagnetic Pulse (EMP) associated with the 10000 Ampere surge
will not be able to develop equivalent currents in parallel conductors
adjacent to the ground wire.  Using a large diameter and avoiding
bends reduces the per length inductance discontinuities.  This
discourages the abandonment of your ground conductor in favor of
nearby metal objects such as power conduits (resulting in hazardous
elevation of the system ground potential to thousands of volts above
the mains).

2. Second order protection -

Protect your primary power entry by use of a surge protector having
four main elements

a.) Line fuses for each hot main NO FUSE FOR THE WHITE NEUTRAL.  No
circuit breakers (too slow).

b.) Self extinguishing gas discharge tubes or arc chutes routed to a
primary ground stake *separated* by 3 or more meters from the umbrella
ground mentioned above, *not* using the same stake, even, and using
the same linear routing algorithm mentioned above.

c.) Heavy gauge inductors, 1 microhenry or thereabouts for typical 30
to 50 Ampere per phase service levels, to choke the surge out of the
consumer side of the system.  NONE IN THE WHITE NEUTRAL.

d.) Post choke line clamping to WHITE NEUTRAL.  This is where the
witchcraft comes in.  One candidate is the Metal Oxide Varistor (MOV).
They have two disadvantages: They age, gradually reducing their
threshold over time until one day they evaporate in a ball of fire
during a line surge.  They have a rather remote threshold
characteristic compared to, say, a Silicon TransZorb.  They have
several advantages: They are cheap.  They come in packaging that is
familiar to professional electricians.  They are generally more robust
than Selenium or Silicon protectors.  They have a smaller geometry
than a Selenium protector.  Another candidate is a combination
protector made up from a ground referenced 50 Ampere triac in series
with either a lower rated voltage MOV or TransZorb element, with the
triac gate wired back to (an artfully positioned) tap on the gas
tube/arc chute ground.  From here (this stuff belongs in a fire-rated
NEMA box) the WHITE NEUTRAL and GREEN NEUTRAL are tied together at
this one point only, and passed through a medium size conductor to the
primary ground stake by a route that is separated by 1.5 meters from
the gas tube/arc chute ground.

Theory:

If your power line gets hit, the gas tube fires and conducts the surge
current to ground.  The 20 kilovolts experienced by your service entry
(for about 10 microseconds) will go through the chokes and will cause
the MOV or complex protector shunt to break down and draw a steadily
rising current (to many tens of Amperes), but immediately choked to a
reduced voltage.  The fuses will, after a while, be blown away.  Until
then, the MOVs will clamp the WHITE NEUTRAL to the mains (perhaps
resulting in noticeable rise of the common-mode voltage).  It is this
common-mode elevation which destroys your out-of-building
communications interfaces.  With everything in the building coming to
2000 volts above your neighbors (including your local telephone
operating company), any common-mode paths will be severely stressed.
However, especially withing the building, they will be less stressed
than they would have been if the mains were allowed to diverge from
the WHITE NEUTRAL.

3. Third level protection

The most effective common-mode protection is an Ultra-Isolator
Transformer.  It is also rather expensive compared to differential
line protectors and secondary Silicon TransZorb protectors.  Although
many Ultra-Isolator Transformers were utilized during the 1970's by
sensitive computer installations, it was realized eventually that the
most damage to main-frame equipment was done by differential surges
(main to main on three-phase systems).  The common-mode threat was
seen as too little to justify the cost and complexity of installation
of an ultra-isolator, which, by the way, can also be done
ineffectively, resulting in no net improvement in the level of
protection.  The companies that make ultra-isolators issue complete
and effective instructions concerning their installation.  The
difficulty is in getting industrial electricians to follow the
directions.  Thus for the benefit of the main-frame and peripheral
power supplies, for cost effective purposes, a good differential surge
eliminator inside the enclosure of each system power supply is
recommended.  However, remember that the common mode is the most
destructive to your distributed data communications peripherals;
unfortunately, to protect them you must provide the entire computer
room and distributed CRT terminal load with an ultra-isolator
transformer, or see that each unit is designed to withstand momentary
local and global differences of thousands of volts on the signal
returns.  Even then, on occasion, only one violator located in a
critical location and tied to a non-isolated power system elsewhere in
the building can blow the whole scheme.  

Theory:

Not much theory here.  The entire primary winding of the transformer
may get lifted to 2000 volts, but the secondary remains referenced to
the computer room ground stake.  The box shields around the the
windings are tied to the stake, and short out the electric field that
might otherwise couple to the secondary.  Saturation of the
transformer core protects the differential mode.  The differential
protectors installed in each power supply dissipate the surges locally
and since each takes a small part of the surge energy, no
concentration of damage will likely occur.

4. Fourth order protection

You may get surge protectors for all communication lines leaving the
building.  Each will need a reliable path to a stout ground.  (DEC
usually specifies that the computer frame GREEN WIRE ground be done
with a heavy gauge wire, and all surge protector grounds be separately
returned to the distribution transformer secondary neutral grounding
point.) You may add Silicon TransZorbs to power supply rails in data
communications equipment.

Theory:

If one of your comm lines gets hit, or gets involved in an induced
surge, the elevation in voltage not dissipated by the protector is
conducted through the internal diode clamps included in most IC line
drivers and receivers to a ground or supply rail, and thence to a
TransZorb (a back-to-back zener with a heavy silver anode and
thermally conductive silver leads).  If enough protectors are in
place, the common-mode surge is clubbed to death by the collective
capability of all peripheral surge protectors operating together.

And that about does it.  Needless to say, if you do a good job of
protecting your site, and one of your neighbors gets hit, you may be
damaged anyhow by currents resulting from the elevation of your
neighbor's electrical ground.  This is especially true in Hawaii (and
even more so on their mountain tops) where the ground is made of lava
rock.  If you get hit by lightning, your entire site goes to 25000
volts with respect to the surrounding neighborhood.  This bleeds down
to appx 2000 volts over the next 100 microseconds or so.

If you have several buildings to worry about, such as may be the case
for a university campus, putting an umbrella protector on every
building will only cause the cloud to ground potential to develop to
the point that when you finally do get a strike, it will be a *real
killer*.  It has been pointed out elsewhere that most lightning
strikes are from the ground up to the cloud.

Thus, More Theory (speculation):

I suspect that the mechanism is something like this: Collisions of air
molecules with each other and the things that make up the surface tend
to knock electrons off the air molecules.  There are other charge pair
generation mechanisms as well, such as natural radioactive decay of
Radon 222 and its decay products.  (This specific mechanism is not my
theory - see JGR Vol 90 No D4 Pgs 5909-5916 June 30, 1985, Edward A
Martell, NCAR.)  The electrons, because of their charge, are sticky.
They cling to the surfaces of various semi-insulators (rocks and dry
dirt) and near the surface of conductors until enough of them are
implanted to provide a counter electrical field gradient to repel
later arrivals.  The positive air ions are separated by thermal
energy, and molecular screening prevents the immediate recombination.
The charge separation is effected by the rising of the warmed
positively ionized air.

Once the charge is separated, mutual repulsion drives the electrons
into the conductive ground layers.  Later, as the air rises and water
condenses, positively charged droplets accumulate in descending air
columns at the front of the storm just ahead of the rising column.  A
field gradient is thus established with respect to the ground, where
all the electrons are.  As the ground is conductive, the electrons
follow the cloud until, with the aid of conductive moisture and the
turbulence of the rising and descending air column interface, leaders
are established and a strike path is ionized and carried into the
descending air.  The electrons travel up the path in a flash (parts of
which will have oscillations at radio frequency) and then distribute
themselves (at a more leisurely pace, accompanied with local flashes
and secondary flashes) in accordance with upper level gradients until
there is nolonger sufficient gradient to ionize the cloud-to-cloud
paths.

Time scales:

Main strike and individual secondary strikes each about 10
microseconds.

Duration of ionized path, reversals and secondaries about 100
microseconds.

Duration of high altitude electrical coronae readjustment about 1
millisecond.

Localized differences in the final potential may result in some
reverse strikes from a few overcharged negative clouds to the ground,
or subsequently more numerously (after air motion), cloud to cloud
"readjustments".

Well, I've done it again.  Darn.  If this is too long, I suppose you
should flame me for it, or if I am guilty of mis-representing known
(un)truths, that would qualify as well.  But I wanted to at least try
to clear up the nature of lightning and its hazards a little.

                                                          Howard Hull
        {ucbvax!hplabs | allegra!nbires | harpo!seismo } !hao!hull

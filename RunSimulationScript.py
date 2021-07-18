print "********************************************";
print "*                                          *";
print "*             TOSSIM Script                *";
print "*                                          *";
print "********************************************";

import sys;
import time;

from TOSSIM import *;

#out = open(simulation_outfile, "w");
out = sys.stdout;

# Number of nodes in the simulated network is 3
number_of_nodes = 10

t = Tossim([])

modelfile="meyer-heavy.txt";	#da capire che cosa è

print "Initializing mac....";
mac = t.mac();
print "Initializing radio channels....";
radio=t.radio();
print "    using topology file:",topofile;
print "    using noise file:",modelfile;
print "Initializing simulator....";
t.init();

#simulation_outfile = "simulation.txt";
#print "Saving sensors simulation output to:", simulation_outfile;
#simulation_out = open(simulation_outfile, "w");


#Add debug channel
print "Activate debug message on channel init"
t.addChannel("init",out);
print "Activate debug message on channel boot"
t.addChannel("boot",out);
print "Activate debug message on channel radio"
t.addChannel("radio",out);
print "Activate debug message on channel radio_send"
t.addChannel("radio_send",out);
print "Activate debug message on channel radio_ack"
t.addChannel("radio_ack",out);
print "Activate debug message on channel radio_rec"
t.addChannel("radio_rec",out);
print "Activate debug message on channel radio_pack"
t.addChannel("radio_pack",out);
print "Activate debug message on channel role"
t.addChannel("role",out);
print "Activate debug message on channel led"
t.addChannel("led",out)

#Boot nodes
time_boot = 0*t.ticksPerSecond();

print "Creating node 1...";
node1 =t.getNode(1);
#time1 = 0*t.ticksPerSecond(); #instant at which each node should be turned on
node1.bootAtTime(time_boot);	#volendo farli partire tutti assieme basta definire il tempo una sola volta

print "Creating node 2...";
node2 = t.getNode(2);
node2.bootAtTime(time_boot);

print "Creating node 3...";
node2 = t.getNode(3);
node2.bootAtTime(time_boot);

print "Creating node 4...";
node2 = t.getNode(4);
node2.bootAtTime(time_boot);

print "Creating node 5...";
node2 = t.getNode(5);
node2.bootAtTime(time_boot);

print "Creating node 6...";
node2 = t.getNode(6);
node2.bootAtTime(time_boot);

print "Creating node 7...";
node2 = t.getNode(7);
node2.bootAtTime(time_boot);

print "Creating node 8...";
node2 = t.getNode(8);
node2.bootAtTime(time_boot);

print "Creating node 9...";
node2 = t.getNode(9);
node2.bootAtTime(time_boot);

print "Creating node 10...";
node2 = t.getNode(10);
node2.bootAtTime(time_boot);

#Open a topology file and parse the data
print "Creating radio channels..."
f = open(topofile, "r");
lines = f.readlines()
for line in lines:
  s = line.split()
  if (len(s) > 0):
    print ">>>Setting radio channel from node ", s[0], " to node ", s[1], " with gain ", s[2], " dBm"
    radio.add(int(s[0]), int(s[1]), float(s[2]))


#creation of channel model
print "Initializing Closest Pattern Matching (CPM)...";
noise = open(modelfile, "r")
lines = noise.readlines()
compl = 0;
mid_compl = 0;

print "Reading noise model data file:", modelfile;
print "Loading:",
for line in lines:
    str = line.strip()
    if (str != "") and ( compl < 10000 ):
        val = int(str)
        mid_compl = mid_compl + 1;
        if ( mid_compl > 5000 ):
            compl = compl + mid_compl;
            mid_compl = 0;
            sys.stdout.write ("#")
            sys.stdout.flush()
        for i in range(1, 3):
            t.getNode(i).addNoiseTraceReading(val)
print "Done!";

for i in range(1, 3):
    print ">>>Creating noise model for node:",i;
    t.getNode(i).createNoiseModel()

print "Start simulation with TOSSIM! \n\n\n";

for i in range(0,1200):
	t.runNextEvent()
	
print "\n\n\nSimulation finished!";

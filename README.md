# proj_lab_iot
progetto finale IoT 2021

cose che ho imparato per ora:
- la topologia è definita del file topology.txt, che viene caricata nel file RunSimulation.py.
- tutti i nodi vengono creati nel file py e il loro address (TOS_ID_ADDRESS) lo definisci tu creandoli. 

logica del progetto 
- node 1 manda messaggi broadcast (per topologia solo a 2-5-8) ogni tot secondi con il un timer. 
- con un ciclo for si decide a che nodo mandare il messaggio, per fare il pattern.
- nel messaggio si mette un campo che per indicare il nodo a cui si vuole arrivare m_ID.
- il receiver confronta il suo TOS_ID con il valore nel capo m_ID, se è uguale blink il led, se è maggiore lo ritrasmette. 

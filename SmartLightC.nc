#include "Timer.h"
#include "SmartLight.h"
#include "printf.h"
#include <stdio.h>
#include <stdint.h>
 
/**
 * Implementation of the SmartLight application. 
 * creare una funzione che a secoda di che pattern vuole, definisce una serie di nodeID. 
 * nodeID [2,3,4,5,7,8,9,10] patter quadrato
 * nodeID [2,4,6,8,10] patter a X
 * nodeID [2,5,6,7,8] patter a T
 * ogni tot un timer periodico fa scattere la task Controller, che a seconda del nodeID manda messaggio unicast al nodo 2, 5, 8. 
**/

module SmartLightC @safe() {


  uses {
    interface Boot;
    interface Leds;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer1;	//del node1 per inviare messaggi a tutti
    interface Timer<TMilli> as MilliTimer2; //ciclo for spegnimento
    interface Timer<TMilli> as MilliTimer3; //ciclo for path
    interface Timer<TMilli> as MilliTimer4; //attesa
    interface SplitControl as AMControl;
    interface Packet;
    interface AMPacket;
  }
  }

implementation {

  message_t packet;
  
  bool locked = FALSE; //busy
  uint16_t pat1[5] = {2,6,8,4,10}; //X
  uint16_t counter = 0;
  uint16_t for1 = 1;
  uint16_t for2 = 0;

	//********Controller Task 1********//
  void Msg_unicast_off(){ 	//messaggio dal node1 per spegnere tutti i nodi
  if (!locked){
  if (TOS_NODE_ID == 1){
   	call MilliTimer2.startPeriodic(1500);
	}
  else {return;}
  }
  else {return;}
  }
  
//********Controller Task 2********//
  void Msg_unicast_on(){
  	if (!locked){
  	if (TOS_NODE_ID == 1){
  		call MilliTimer3.startPeriodic(1500);
		}
	else {return;}	
	}
	else {return;}
  }

//********forward fuction********//
  void forward(uint16_t d, uint16_t f){
  	if (locked) {return;}
  	else {
  	uint16_t a = d;
  	uint16_t b= f;
    	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
    	printf("forward function: a=%d, b =%d\n",a,b);
    	msg->nodeID = a;
    	msg->flag_led = b;
    	printf("forward function: nodeID=%d\n",msg->nodeID);
  		if (call AMSend.send(TOS_NODE_ID+1, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {
  			printf("packet forwarded from %d to %d\n nodeID %d.\n",TOS_NODE_ID, TOS_NODE_ID+1, msg->nodeID);
			locked = TRUE; }
	}
  }
	

	//*******Boot Interface*****//
  event void Boot.booted() {
    printf("Application booted for node (%d).\n",TOS_NODE_ID);
    call AMControl.start();
  }
	//*******SplitControl Interface****//
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Radio is on!\n"); 
      if (TOS_NODE_ID == 1){
      call MilliTimer1.startPeriodic(20000);
      }
    }
    else {
      call AMControl.start();
    }
    }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  //*********MilliTimer1 Interface*******//
  event void MilliTimer1.fired() {
  if (locked) {
  	return;}
    counter++;
    printf("timer1 fired, counter is %d.\n", counter);
      if (counter%2 != 0){
      	Msg_unicast_on(); }	
      if (counter%2 == 0){
      	Msg_unicast_off(); } 
      else 
      	{return;}
    }
  
  //*********MilliTimer2 Interface*******//
  event void MilliTimer2.fired() { 	//ciclo for1 
    printf("timer2 fired\n");
    if (locked) {
    printf("timer2: locked");
      return; }
    else {
    for1++;
    printf("timer2: counter is %d.\n", for1);
    	if(for1 == 2 || for1 == 3 || for1 == 4){	  //routing
    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 			msg->flag_led = 0; 		//messaggio di tipo spegni
 			msg->nodeID = for1;	
  	 		if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
			printf("packet sent to node 2, with nodeID =%d.\n", msg->nodeID);
			locked = TRUE; 
			}
		}
		if(for1 == 5 || for1 == 6 || for1 == 7){	//routing
			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 			msg->flag_led = 0; 		//messaggio di tipo spegni
 			msg->nodeID = for1;
  	  		if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
			printf("packet sent to node 5, with nodeID =%d.\n", msg->nodeID);
			locked = TRUE; 
			}
		}
		if(for1 == 8 || for1 == 9 || for1 == 10){	//routing
			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 			msg->flag_led = 0; 		//messaggio di tipo spegni
 			msg->nodeID = for1;
  	  		if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
			printf("packet sent to node 8, with nodeID =%d.\n", msg->nodeID);
			locked = TRUE; 
			}
		}
		if(for1 == 11){
			for1 = 1;
			call MilliTimer2.stop();
		}
    }
  }
  
  //*********MilliTimer3 Interface*******//
  event void MilliTimer3.fired() { 	//ciclo for2 
    
    printf("timer3 fired\n");
    if (locked) {
    printf("timer2: locked");
      return; }
    else {
    printf("timer3 fired, counter is %d.\n", for2);
    printf("pat1[%d] is %d.\n", for2, pat1[for2]);
    	if (pat1[for2] == 2 || pat1[for2] == 3 || pat1[for2] == 4){
  			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[for2]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				printf("packet sent to node 2, with nodeID =%d.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
    		if (pat1[for2] == 5 || pat1[for2] == 6 || pat1[for2] == 7){
    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[for2]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				printf("packet sent to node 5, with nodeID =%d.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
	    	if (pat1[for2] == 8 || pat1[for2] == 9 || pat1[for2] == 10){
	    	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[for2]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				printf("packet sent to node 8, with nodeID =%d.\n", msg->nodeID);
				locked = TRUE; 
				}
			}
		if(for2 == 4){
		    for2=-1;
			call MilliTimer3.stop();
		}
	for2++;
    }
  }
  
  event void MilliTimer4.fired(){
  printf("timer4 fired\n");
  //do nothing
  }
   
  //********Receive Event Interface********//
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
  	smart_light_msg_t* msg = (smart_light_msg_t*)payload;
    printf("Received function: at node %d with nodeID %d\n", TOS_NODE_ID, msg->nodeID);   
    if (len != sizeof(smart_light_msg_t)) {return bufPtr;}
    else {
    	if (msg->nodeID == TOS_NODE_ID){
    		printf("nodeID=TOS_NODE_ID: packet recived at node %d\n", TOS_NODE_ID);
    		printf("Payload length %d\n", call Packet.payloadLength(&packet));
        	printf("Payload \n");
        	printf("node_id:  %d \n", msg->nodeID);
        	printf("flag_led: %d \n", msg->flag_led);
        	if (msg->flag_led == 1){call Leds.led0On();}
        	if (msg->flag_led == 0){call Leds.led0Off();}
        	locked = FALSE;
         }
         if (msg->nodeID != TOS_NODE_ID) {
         		printf("call forward function\n");
         		forward(msg->nodeID, msg->flag_led);
				
         }
    }
  }
  
  //********Senddone Event Interface********//
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
    locked = FALSE;
    	call MilliTimer4.startOneShot(1000);
    	printf("Packet sent...");
	}
      else{
      printf("Send done error!"); 
    }
  }
  
  
  }

#include "Timer.h"
#include "SmartLight.h"
#include "printf.h"
#include <stdio.h>
#include <stdint.h>
 
/**
 * Implementation of the SmartLight application. 
 * A slower timer is used to switch between "ights on" and "lights off" states
 * Two faster timers are used to send messages to each light node 
 * X pattern: [2,4,6,8,10] 
 * T pattern: [2,5,6,7,8] 
 * Diamond pattern: [3,5,6,7,9] 
**/

module SmartLightC @safe() {

	uses {
    	interface Boot;
    	interface Leds;
		interface Receive;
		interface AMSend;
		interface Timer<TMilli> as MilliTimer1;	//to switch between actions
    	interface Timer<TMilli> as MilliTimer2; //used to turn off all the light nodes
    	interface Timer<TMilli> as MilliTimer3; //used to display the pattern
    	interface SplitControl as AMControl;
    	interface Packet;
    	interface AMPacket;
  	}
}

implementation {

	message_t packet;
  
	bool locked = FALSE; //not busy
	uint16_t pat[5];
	uint16_t pat1[] = {2,4,6,8,10}; //X pattern
	uint16_t pat2[] = {2,5,6,7,8};	 //T pattern
	uint16_t pat3[] = {3,5,6,7,9};	 //diamond pattern
	uint16_t count_pat = 0;	//counter to switch between the pattern
	uint16_t t1 = 0;	//variable of Timer1
	uint16_t t2 = 1;	//variable of Timer2
	uint16_t t3 = 0;	//variable of Timer3
	uint16_t i = 0;		//variable of the for-loop

//********Controller Task 1: turning off the light nodes********//
	void Msg_unicast_off(){ 
		if (!locked){				
			if (TOS_NODE_ID == 1){	
   			call MilliTimer2.startPeriodic(1000);	}
  			else {return;}
  		}
  		else {return;}
  	}
  
//********Controller Task 2: turning on the light nodes wrt patterns********//
	void Msg_unicast_on(){	 
		if (!locked){
			if (TOS_NODE_ID == 1){
			count_pat++;
  			call MilliTimer3.startPeriodic(1000);	}
			else {return;}	
		}
		else {return;}
  	}

//********forward fuction********//
	void forward(uint16_t d, uint16_t f){		
		if (locked) {return;}
		else {
			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
			msg->nodeID = d;
			msg->flag_led = f;
    		printf("forward function: nodeID = %d, flag_led = %d\n",msg->nodeID, msg->flag_led);
  			if (call AMSend.send(TOS_NODE_ID+1, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {
  				printf("packet forwarded from %d to %d with nodeID = %d and flag_led = %d.\n",TOS_NODE_ID, TOS_NODE_ID+1, msg->nodeID, msg->flag_led);
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
				call MilliTimer1.startPeriodic(11000);	}
		}
    	else {
			call AMControl.start();	}
    }

	event void AMControl.stopDone(error_t err) {
		// do nothing
	}
  
//*********MilliTimer1: every 11sec switch between "off" and "on" states*******//
	event void MilliTimer1.fired() {
		if (locked) {return;}
			t1++;
			printf("Timer1(11s) fired, counter is %d.\n", t1);
      		if (t1%2 != 0){
      			printf("Timer1(11s): LIGHTS ON.\n");
      			Msg_unicast_on(); }	
      		if (t1%2 == 0){
      			printf("Timer1(11s): LIGHTS OFF.\n");
      			Msg_unicast_off(); } 
      	else 
      		{return;}
	}
  
//*********MilliTimer2: every 1.5s send a message to turn the lights off*******//
	event void MilliTimer2.fired() { 
    	if (locked) {return;}
    	else {
    		t2++;
    		printf("Timer2(1s) is fired: counter is %d.\n", t2);
    		if(t2 == 2 || t2 == 3 || t2 == 4){	  //routing
    			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 				msg->flag_led = 0; 		//off message
 				msg->nodeID = t2;	
  	 			if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
					printf("packet sent to node 2, with nodeID =%d.\n", msg->nodeID);
					locked = TRUE;	}
			}
			if(t2 == 5 || t2 == 6 || t2 == 7){	//routing
				smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 				msg->flag_led = 0; 		//off message
 				msg->nodeID = t2;
  	  			if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
				printf("packet sent to node 5, with nodeID =%d.\n", msg->nodeID);
				locked = TRUE;	}
			}
			if(t2 == 8 || t2 == 9 || t2 == 10){	//routing
				smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
 				msg->flag_led = 0; 		//off message
 				msg->nodeID = t2;
  	  			if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
				printf("packet sent to node 8, with nodeID =%d.\n", msg->nodeID);
				locked = TRUE;	}
			}
			if(t2 == 11){
			t2 = 1;	//reset variable to the starting value
			printf("reset counter t2\n");
			call MilliTimer2.stop();	}
    	}
	}
  
//*********MilliTimer3: every 1s send a message to all the light nodes to turn them off*******//
	event void MilliTimer3.fired() { 	 
    	if (locked) {return;}
    	else {
    		printf("Timer3(1s) fired, counter is %d.\n", t3);  	
	    	if (count_pat==4) {	count_pat=1;}
	    	if (count_pat==1) { 
	    		printf("count_pat = %d\n", count_pat);	
	    		for(i=0;i<5;i++){	
	    			pat[i]=pat1[i];}
	    		printf("X PATTERN: nodes [%d, %d, %d, %d, %d]\n", pat[0],pat[1],pat[2],pat[3],pat[4]);}
	    	if (count_pat==2) {	
	    		printf("count_pat = %d\n", count_pat);
	    		for(i=0;i<5;i++){
	    			pat[i]=pat2[i];}
	    		printf("T PATTERN nodes [%d, %d, %d, %d, %d]\n", pat[0],pat[1],pat[2],pat[3],pat[4]);}
	    	if (count_pat==3) {	
	    		printf("count_pat = %d\n", count_pat);
	    		for(i=0;i<5;i++){
	    			pat[i]=pat3[i];}
	    		printf("DIAMOND PATTERN: nodes [%d, %d, %d, %d, %d]\n", pat[0],pat[1],pat[2],pat[3],pat[4]);}
	    	if (pat[t3] == 2 || pat[t3] == 3 || pat[t3] == 4){
	  			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
	  			msg->nodeID = pat[t3]; 
	  			msg->flag_led = 1;		//on message
	  			if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
					printf("packet sent to node 2, with nodeID =%d.\n", msg->nodeID);
					locked = TRUE;	}
			}	
	    	if (pat[t3] == 5 || pat[t3] == 6 || pat[t3] == 7){
	    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
	  			msg->nodeID = pat[t3]; 
	  			msg->flag_led = 1;		//on message
	  			if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
					printf("packet sent to node 5, with nodeID =%d.\n", msg->nodeID);
					locked = TRUE;	}
			}	
		   	if (pat[t3] == 8 || pat[t3] == 9 || pat[t3] == 10){
		   		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
	  			msg->nodeID = pat[t3]; 
	  			msg->flag_led = 1;		//on message
	  				if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		
						printf("packet sent to node 8, with nodeID =%d.\n", msg->nodeID);
						locked = TRUE; }
			}	
			if(t3 == 4){
		    t3=-1;	//reset to initial value
		    printf("reset counter t3\n");
			call MilliTimer3.stop();	
			}
		t3++;
		}
	}
  
   
//********Receive Event Interface********//
	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		smart_light_msg_t* msg = (smart_light_msg_t*)payload;
		printf("Received function: message received at node %d with nodeID = %d and flag_led = %d\n", TOS_NODE_ID, msg->nodeID, msg->flag_led);   
    	if (len != sizeof(smart_light_msg_t)) {return bufPtr;}
    	else {
    		if (msg->nodeID == TOS_NODE_ID){
    			printf("nodeID = TOS_NODE_ID: packet recived at node %d\n", TOS_NODE_ID);
    			printf("Payload:\n");
        		printf("node_id:  %d\n", msg->nodeID);
        		printf("flag_led: %d\n", msg->flag_led);
        		if (msg->flag_led == 1){call Leds.led0On();	//turn on all the leds
        								call Leds.led1On();
        								call Leds.led2On();}
        		if (msg->flag_led == 0){call Leds.led0Off();	//turn off all the leds
        								call Leds.led1Off();
        								call Leds.led2Off();}
        		locked = FALSE;
        		return bufPtr;	}	
			if (msg->nodeID != TOS_NODE_ID) {
				forward(msg->nodeID, msg->flag_led);
         		locked = FALSE;
         		return bufPtr;	}
    	}
    	return bufPtr;
	}
  
//********Senddone Event Interface********//
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			locked = FALSE;
 			printf("Packet sent...\n");	}
		else{
			printf("Send done error!"); 
		}
	}
    
} 

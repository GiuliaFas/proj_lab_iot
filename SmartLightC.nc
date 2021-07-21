#include "Timer.h"
#include "SmartLight.h"
 
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
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
    interface AMPacket;
  }
}
implementation {

  message_t packet;

  bool locked; //busy
  uint16_t a = 0;	//contatore per i cicli for broadcast
  uint16_t i = 0;	//contatore per i cicli for unciast
  uint16_t j = 0;	//contatore per i cicli for unicast
  uint16_t k = 0;	//contatore per i cicli for unicast
  uint16_t b = 0;	//contatore per i cicli for unicast
  uint16_t counter = 0;
  uint16_t counter_pat = 0;					//to choose the light's pattern 
  uint16_t pat1[5] = {3,5,6,7,9};				//	->
  uint16_t pat2[5] = {2,4,6,8,10};				//X
  uint16_t pat3[5] = {2,5,6,7,8};				//T
  
	//********************Boot Interface****************//
  event void Boot.booted() {
    dbg("Boot","Application booted for node (%d).\n",TOS_NODE_ID);
    call AMControl.start();
  }
	//********************SplitControl Interface*************//
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      dbg("Radio","Radio is on!\n");
      call MilliTimer.startPeriodic(500);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  
  
  //***********************Controller Task 1*************************//
  void Msg_broadcast_1(){
  smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  for (a=0; a<8; a++){ 	//per tutti i nodi luce
  	if (msg == NULL) {
      return;}
    else{  	  
  	msg->nodeID = a;
  	msg->flag_led = 0;		//messaggio di tipo spegni
  	  if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
	  dbg("SmartLightC", "SmartLightC: packet sent broadcast, with nodeID =%hhu.\n", msg->nodeID);
	  locked = TRUE; 
		}
	}
  }
  }
  //***********************Controller Task 2*************************//
  void Msg_unicast_1(){
  	if (!locked){
  	b++;	//contatore per il ciclo dei pat
    counter_pat++;	//anytime the timer is fired, change the pattern
  	if (counter_pat == 1+6*b){		//pat: arrow
  		for (i=0; i<4; i++){
  			if (pat1[i] == 2 || pat1[i] == 3 || pat1[i] == 4){
  			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 2, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
    		if (pat1[i] == 5 || pat1[i] == 6 || pat1[i] == 7){
    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 5, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
	    	if (pat1[i] == 8 || pat1[i] == 9 || pat1[i] == 10){
	    	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 8, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}
		}	
	}
	if (counter_pat == 3+6*b){		//pat: X
  		for (j=0; j<4; j++){
  			if (pat2[j] == 2 || pat2[j] == 3 || pat2[j] == 4){
  			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 2, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
    		if (pat2[j] == 5 || pat2[j] == 6 || pat2[j] == 7){
    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 5, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
	    	if (pat2[j] == 8 || pat2[j] == 9 || pat2[j] == 10){
	    	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 8, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}
		}	
	}
	if (counter_pat == 5+6*b){		//pat: T
  		for (k=0; k<4; k++){
  			if (pat3[k] == 2 || pat3[k] == 3 || pat3[k] == 4){
  			smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(2, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 2, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
    		if (pat3[k] == 5 || pat3[k] == 6 || pat3[k] == 7){
    		smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(5, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 5, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}	
	    	if (pat3[k] == 8 || pat3[k] == 9 || pat3[k] == 10){
	    	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
  			msg->nodeID = pat1[i]; //dai alla variabile nodeID nel paylod il valore del pat
  			msg->flag_led = 1;		//messaggio di tipo accendi
  				if (call AMSend.send(8, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node 8, with nodeID =%hhu.\n", msg->nodeID);
				locked = TRUE; 
				}
			}
		}	
	}
	}
	}
	
	//************************MilliTimer Interface********************//
  event void MilliTimer.fired() {
    counter++;
    dbg("SmartLightC", "SmartLightC: timer fired, counter is %hu.\n", counter);
    if (locked) {
      return; }
    else {
      if (counter%2 != 0){
      	Msg_unicast_1(); }	//ogni volta che scatta il timer a tempo dispari, chiama il controllore 
      else{
      	Msg_broadcast_1(); }
    }
  }
	//***********************Receive Event Interface*************************//
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
  	smart_light_msg_t* msg = (smart_light_msg_t*)(call Packet.getPayload(&packet, sizeof(smart_light_msg_t)));
    dbg("SmartLightC", "Received packet from node %hhu.\n", call AMPacket.source (&packet));
    if (len != sizeof(smart_light_msg_t)) {return bufPtr;}
    else {
    	if (TOS_NODE_ID == msg->nodeID){
    		dbg("SmartLightC", "SmartLightC: packet recived at node %hhu, at time %s \n", TOS_NODE_ID, sim_time_string());
    		dbg_clear ("Pkg",">>>Pack \n \t Payload length %hhu \n", call Packet.payloadLength (&packet));
    	    dbg_clear ("Pkg","\t Source: %hhu \n", call AMPacket.source (&packet));
       		dbg_clear ("Pkg","\t Destination: %hhu \n", call AMPacket.destination (&packet));
        	dbg_clear ("Pkg","\t\t Payload \n");
        	dbg_clear ("Pkg","\t\t node_id:  %hhu \n", msg->nodeID);
        	dbg_clear ("Pkg","\t\t flag_led: %hhu \n", msg->flag_led);
        	dbg_clear ("Pkg","\n");
        	if (msg->nodeID == 2 && msg->flag_led == 1) { call Leds.led0On(); }	//se il messaggio è diretto a me e la flag è 1 accendi il led
        	if (msg->nodeID == 3 && msg->flag_led == 1) { call Leds.led1On(); }
        	if (msg->nodeID == 4 && msg->flag_led == 1) { call Leds.led2On(); }
        	if (msg->nodeID == 5 && msg->flag_led == 1) { call Leds.led3On(); }
        	if (msg->nodeID == 6 && msg->flag_led == 1) { call Leds.led4On(); }
        	if (msg->nodeID == 7 && msg->flag_led == 1) { call Leds.led5On(); }
        	if (msg->nodeID == 8 && msg->flag_led == 1) { call Leds.led6On(); }
        	if (msg->nodeID == 9 && msg->flag_led == 1) { call Leds.led7On(); }
        	if (msg->nodeID == 10 && msg->flag_led == 1) { call Leds.led8On(); }
        	if (msg->nodeID == 2 && msg->flag_led == 0) { call Leds.led0Off(); }	//se il messaggio è diretto a me e la flag è 0 spegni il led
        	if (msg->nodeID == 3 && msg->flag_led == 0) { call Leds.led1Off(); }
        	if (msg->nodeID == 4 && msg->flag_led == 0) { call Leds.led2Off(); }
        	if (msg->nodeID == 5 && msg->flag_led == 0) { call Leds.led3Off(); }
        	if (msg->nodeID == 6 && msg->flag_led == 0) { call Leds.led4Off(); }
        	if (msg->nodeID == 7 && msg->flag_led == 0) { call Leds.led5Off(); }
        	if (msg->nodeID == 8 && msg->flag_led == 0) { call Leds.led6Off(); }
        	if (msg->nodeID == 9 && msg->flag_led == 0) { call Leds.led7Off(); }
        	if (msg->nodeID == 10 && msg->flag_led == 0) { call Leds.led8Off(); }
         }
         if (TOS_NODE_ID > msg->nodeID){
         	if (call AMSend.send(TOS_NODE_ID+1, &packet, sizeof(smart_light_msg_t)) == SUCCESS) {		//manda il messaggio
				dbg("SmartLightC", "SmartLightC: packet sent to node %hhu.\n", call AMPacket.destination (&packet));
				locked = TRUE; }
         }
    }
  }
  
//***********************Senddone Event Interface*************************//
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
    locked = FALSE;
    	  dbg("radio_send", "Packet sent...");
		  dbg_clear("radio_send", " at time %s \n", sim_time_string());
	}
      else{
      dbgerror("radio_send", "Send done error!");
      
    }
  }

//whenever it receives a packet : Toggle red
#include <Timer.h>
#include <string.h>
#include <stdio.h>
#include "Base.h"

module BaseC {
	uses interface Boot;
	uses interface Leds;

	// Radio Interface
	uses interface Packet;
	uses interface SplitControl as MHControl;
	uses interface Receive;
	uses interface AMPacket as MHPacket;
	uses interface AMSend as MHSend;

	// Timers for groups
	uses interface Timer<TMilli> as group1;
	
	
}
implementation {

	
	base_grp a;

	uint16_t centiG;
	uint16_t new_mean;

	//Queues 
	message_t sendQueueBufs[QUEUE_LEN];
	message_t * ONE_NOK sendQueue[QUEUE_LEN];
	uint8_t sin, sout, scnt;
	bool sfull, sbusy;

	message_t receiveQueueBufs[QUEUE_LEN];
	message_t * ONE_NOK receiveQueue[QUEUE_LEN];
	uint8_t rin, rout, rcnt;
	bool rfull, rbusy;

	// Tasks
	task void sendTask();
	task void receiveTask();

	void init() {
		uint8_t i;

		//TOS_NODE_ID = 1;

		for(i = 0; i < QUEUE_LEN; i++) 
			sendQueue[i] = &sendQueueBufs[i];
		sin = sout = 0;
		scnt = 0;
		sfull = FALSE;
		sbusy = FALSE;

		for(i = 0; i < QUEUE_LEN; i++) 
			receiveQueue[i] = &receiveQueueBufs[i];
		rin = rout = 0;
		rcnt = 0;
		rfull = FALSE;
		rbusy = FALSE;
	}
	// mean is set to 0 init
	void group_init(base_grp * a, uint8_t groupid, uint16_t startid,
			uint16_t num) {
		uint8_t i;
		a->groupid = groupid;
		a->num = num;
		a->startid = startid;

		a->mean = 0;
		a->poll_cnt = 0;
		a->em_cnt = 0;

		a->polling = FALSE;

		for(i = 0; i < num; i++) {
			a->em_p[i] = 0;
			a->temp[i] = 0;
		}

	}

	event void Boot.booted() {
		init();
		group_init(&a, 1, 8, 6);
		call MHControl.start();
		call Leds.led1On();
	}

	event void MHControl.startDone(error_t error) {
		if(error == SUCCESS) {
			call group1.startPeriodic(30000);
		}
		else {
			call MHControl.start();
		}
	}

	event void MHControl.stopDone(error_t error) {
	}

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		
		message_t * ret = msg;
		atomic {
			if( ! rfull) {
				ret = receiveQueue[rin];
				receiveQueue[rin] = msg;

				rin = (rin + 1) % QUEUE_LEN;
				rcnt++;

				if(rcnt == QUEUE_LEN) 
					rfull = TRUE;

				if( ! rbusy) {
					post receiveTask();
					rbusy = TRUE;
				}
			}
			else {
				// drop packet
			}
		}

		return ret;
	}

	

	task void receiveTask() {
		// 1. poll reply packets, em ping packets
		message_t * tmp;
		BlinkToRadioMsg * b;
		if(rcnt != 0) {
			rbusy = TRUE;

			tmp = receiveQueue[rout];
			b = (BlinkToRadioMsg * )(call Packet.getPayload(tmp,
					sizeof(BlinkToRadioMsg)));
			if(b->type == POLL_REPLY) {
				printf("POLL REPLY :\n Node: %d, Temp: %d, Mean %d volt %d\n", b->nodeid,b->temp, b->mean,b->volt);
			}
			else 
				if(b->type == EM_PING) {
				printf("EM PING :\n Node: %d, Temp: %d, Mean %d volt %d\n", b->nodeid ,b->temp, b->mean,b->volt);
				
			}
			rout = (rout + 1) % QUEUE_LEN;
			rcnt--;
			rbusy = FALSE;
		}
		if(rcnt != 0) 
			post receiveTask();
	}
	

	// Sending the packet using multicast
	task void sendTask() {

		message_t * tmp;
		uint16_t target;
		BlinkToRadioMsg * b;
		tmp = sendQueue[sout];
		b = (BlinkToRadioMsg * )(call Packet.getPayload(tmp,
				sizeof(BlinkToRadioMsg)));
		target = b->nodeid;
		printf("POLL N%d:\n", target);
		call MHSend.send(target, tmp, sizeof(BlinkToRadioMsg));

	}

	event void MHSend.sendDone(message_t * msg, error_t error) {
		if(msg == sendQueue[sout]) {
			sout = (sout + 1) % QUEUE_LEN;
			scnt--;
			//printf("-send done scnt = %d-\n", scnt);
		}
		if(scnt == 0) 
			sbusy = FALSE;
		if(scnt != 0)
			post sendTask();

	}
	void multicast(base_grp a, uint16_t type, uint16_t mean) {
		message_t * tmp;
		BlinkToRadioMsg * b;
		uint8_t i;
		atomic {
			//printf("Into Multicast-\n");
			for(i = 0; i < a.num; i++) {
				if( ! sfull) {
					tmp = sendQueue[sin];
					b = (BlinkToRadioMsg * )(call Packet.getPayload(tmp,
							sizeof(BlinkToRadioMsg)));
					b->type = type;
					b->nodeid = a.startid + i;
					b->mean = mean;
					b->temp = 0;
					sin = (sin + 1) % QUEUE_LEN;
					scnt++;

					if(scnt == QUEUE_LEN) 
						sfull = TRUE;

				}
				if( ! sbusy) {
					sbusy = TRUE;
					post sendTask();

				}
			}
		}
	}
	event void group1.fired() {
		printf("TIMER FIRED\n");
		multicast(a, POLL, 0);

	}

}

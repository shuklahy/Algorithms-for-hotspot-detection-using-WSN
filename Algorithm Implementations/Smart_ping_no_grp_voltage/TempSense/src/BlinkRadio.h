
typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t temp;
  nx_uint16_t type;	
  nx_uint16_t mean;
  nx_uint16_t volt;
} BlinkToRadioMsg;

enum{
	POLL_REPLY = 10,
	POLL = 20,
	MEAN = 30,
	EM_PING = 40,
	RESET = 50
};
enum {
  TIMER_PERIOD_MILLI = 1000
};

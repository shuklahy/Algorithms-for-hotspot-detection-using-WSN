#define MAX 100
typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t temp;
  nx_uint16_t type;	
  nx_uint16_t mean;
  nx_uint16_t volt;
} BlinkToRadioMsg;

typedef nx_struct base_grp{
	nx_uint16_t num;
	nx_uint8_t groupid;
	nx_uint16_t startid;
	
	nx_uint16_t mean;
	
	nx_uint16_t em_p[MAX];
	nx_uint16_t em_cnt;
	
	nx_uint16_t temp[MAX];
	nx_uint16_t poll_cnt;
    nx_bool polling;	
}base_grp;

enum{
	POLL_REPLY = 10,
	POLL = 20,
	MEAN = 30,
	EM_PING = 40,
	RESET = 50
};
enum {
  TIMER_PERIOD_POLL = 4000,
  TIMER_PERIOD_MEAN = 20000
};

enum{
	QUEUE_LEN = 15
};
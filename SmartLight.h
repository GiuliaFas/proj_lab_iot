#ifndef SMART_LIGHT_MSG_H
#define SMART_LIGHT_MSG_H

typedef nx_struct smart_light_msg {
  nx_uint16_t nodeID;
  nx_uint16_t flag_led;
} smart_light_msg_t;

enum {
  AM_SMART_LIGHT_MSG = 6,
};

#endif

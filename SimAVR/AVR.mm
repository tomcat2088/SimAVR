//
//  AVR.m
//  SimAVR
//
//  Created by wangyang on 2017/2/22.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "AVR.h"

#include <iostream>
#include <sstream>
#include <string>
#include <cstring>
#include <map>
#include <limits>
using namespace std;

#include <stdio.h>
#include <stdlib.h>
#ifndef _MSC_VER
#  include <getopt.h>
#else
#  include "getopt/getopt.h"
#  define VERSION "(git-snapshot)"
#endif

#include "config.h"

#include "flash.h"
#include "avrdevice.h"
#include "avrfactory.h"
#include "avrsignature.h"
#include "avrreadelf.h"
#include "gdb.h"
#include "ui/ui.h"
#include "systemclock.h"
#include "ui/lcd.h"
#include "ui/keyboard.h"
#include "traceval.h"
#include "ui/scope.h"
#include "string2.h"
#include "helper.h"
#include "specialmem.h"
#include "irqsystem.h"

#include "dumpargs.h"

@implementation AVR
+ (void)run:(NSString *)elfFile {
    std::string devicename = "atmega16";
    std::string filename = [[[NSBundle mainBundle] pathForResource:@"simple_serial" ofType:@".elf"] UTF8String];

    /* get dump manager and inform it, that we have a single device application */
    DumpManager *dman = DumpManager::Instance();
    dman->SetSingleDeviceApp();

    /* check, if devicename is given or get it out from elf file, if given */
    unsigned int sig;
    char *new_devicename = (char *)malloc(1024); // can't be static

    strncpy(new_devicename, devicename.c_str(), 1024);
    if(filename != "unknown") {
        sig = ELFGetDeviceNameAndSignature(filename.c_str(), new_devicename);
    }

    /* now we create the device and set device name and signature */
    AvrDevice *dev1 = AvrFactory::instance().makeDevice(new_devicename);
    dev1->SetDeviceNameAndSignature(new_devicename, sig);
    free(new_devicename);

    //if we want to insert some special "pipe" Registers we could do this here:

    if(filename != "unknown" ) {
        dev1->Load(filename.c_str());
        dev1->Reset(); // reset after load data from file to activate fuses and lockbits
    }

    if(dev1->GetClockFreq() == 0) {
        avr_warning("Clock frequency not given, defaulting to 4000000. "
                        "Use -F | --cpufrequency FREQ or insert a "
                        "SIMINFO_CPUFREQUENCY(freq) macro into your source %s",
                "to specify it.");
        dev1->SetClockFreq((SystemClockOffset)1000000000 / 4000000);
    }
    avr_message("Running with CPU frequency: %1.3lf MHz (%lld Hz)\n",
            (double)1000 / dev1->GetClockFreq(),
            (unsigned long long)1000000000 / dev1->GetClockFreq());

    if(sysConHandler.GetTraceState())
        dev1->trace_on = 1;

    dman->start(); // start dump session

    int maxRunTime = 0;
    long steps = 0;
    SystemClock::Instance().Add(dev1);
    if(maxRunTime == 0) {
        steps = SystemClock::Instance().Endless();
        cout << "SystemClock::Endless stopped" << endl
             << "number of cpu cycles simulated: " << dec << steps << endl;
    } else {                                           // limited
        steps = SystemClock::Instance().Run(maxRunTime);
        cout << "Ran too long. Terminated after "
             << dec << steps << " cpu cycles simulated." << endl;
    }
    Application::GetInstance()->PrintResults();


    dman->stopApplication(); // stop dump session. Close dump files, if necessary

    delete dev1;
}
@end

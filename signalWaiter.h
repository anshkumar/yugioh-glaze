#ifndef SIGNALWAITER_H
#define SIGNALWAITER_H

#include <QMutex>
#include <QWaitCondition>

class SignalWaiter {
private:
    QMutex mutex;
    QWaitCondition waitCondition;
    bool signalled;

public:
    SignalWaiter() {
        signalled = false;
    }

    void set() {        
        mutex.lock();
        signalled = true;
        waitCondition.wakeAll();
        mutex.unlock();
    }

    void reset() {
        mutex.lock();
        signalled = false;
        mutex.unlock();
    }

    void wait() {
        mutex.lock();
        while (!signalled) {
            waitCondition.wait(&mutex);
        }
        signalled = false;
        mutex.unlock();
    }
};

#endif // SIGNALWAITER_H


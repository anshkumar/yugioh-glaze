#ifndef SIGNALWAITER_H
#define SIGNALWAITER_H

#include <QMutex>
#include <QWaitCondition>

class SignalWaiter {
private:
    QMutex mutex;
    QWaitCondition waitCondition;
    bool signalled;
    bool _nowait;

public:
    SignalWaiter() {
        signalled = false;
        _nowait = false;
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
        if(_nowait)
            return;
        while (!signalled) {
            waitCondition.wait(&mutex);
        }
        signalled = false;
        mutex.unlock();
    }

    void setNoWait(bool nowait) {
            _nowait = nowait;
        }
};

#endif // SIGNALWAITER_H


#ifndef SINGLEAPPLICATION_H
#define SINGLEAPPLICATION_H

#include <QtCore>

class SingleApplication : public QObject
{
    Q_OBJECT

private:
    static QLockFile g_lockFile;

public:
    explicit SingleApplication(QObject *parent = nullptr)
        : QObject(parent),
          m_lockFile(QDir::tempPath() + "/" + QFileInfo(QCoreApplication::applicationFilePath()).fileName() + "-3356-4ce-lockfile")
    {
        if (!m_lockFile.isLocked()) {
            m_lockFile.tryLock(100);
        }
    }

    Q_INVOKABLE bool isRunning() { return !m_lockFile.isLocked(); }

private:
    QLockFile m_lockFile;
};

#endif // SINGLEAPPLICATION_H

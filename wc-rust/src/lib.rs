use std::thread;
use std::sync::mpsc;
use std::sync::Arc;
use std::sync::Mutex;

trait FnBox {
    fn call_box(self: Box<Self>);
}

impl<F: FnOnce()> FnBox for F {
    fn call_box(self: Box<F>) {
        (*self)()
    }
}

type Job = Box<FnBox + Send + 'static>;

enum Message {
    NewJob(Job),
    Terminate,
}

struct Worker {
    handle: Option<thread::JoinHandle<()>>
}

impl Worker {
    pub fn new(receiver: Arc<Mutex<mpsc::Receiver<Message>>>) -> Worker {
        let handle = thread::spawn(move || {
            loop {
                let message = receiver.lock().expect("Error taking lock").recv().expect("Error receiving message");

                match message {
                    Message::NewJob(job) => {

                        job.call_box();
                    },
                    Message::Terminate => {
                        break;
                    },
                }
            }
        });
        Worker {
            handle: Some(handle),
        }
    }
}

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: mpsc::Sender<Message>,
}

impl ThreadPool {
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let mut workers = Vec::with_capacity(size);

        let (sender, receiver) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(receiver));

        for _ in 0..size {
            workers.push(Worker::new(Arc::clone(&receiver)));
        }

        ThreadPool {
            workers,
            sender,
        }

    }

    pub fn execute<F>(&self, f: F)
        where
            F: FnOnce() + Send + 'static
    {
        let job = Box::new(f);
        self.sender.send(Message::NewJob(job)).expect("Error sending job.");
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {

        for _ in &self.workers {
            self.sender.send(Message::Terminate).expect("Error sending terminate to workers.");
        }

        for worker in &mut self.workers {
            if let Some(handle) = worker.handle.take() {
                handle.join().expect("Error waiting for thread on handle.");
            }
        }
    }
}

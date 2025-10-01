'''
    Demonstrates Jac's scale-agnostic design. The same code runs locally 
    can seamlessly scale to cloud deployment without modification. Bt running
    the cmd `jac serve filename.jac`, the `walkers` become API endpoints
     that can be called via HTTP requests. This shows how Jac applications
     are inherently cloud-ready

'''
import random;

walker GuessGame {
    has guess: int;

    can start with `root entry;
    can process_guess with turn entry;

}

node turn {
    has correct_number: int = random.randint(1, 10);
}

#will run when in CLI mode (not in cloud)

with entry: __main__ {
    root spawn GuessGame(1);
    root spawn GuessGame(4);
    root spawn GuessGame(5);
    root spawn GuessGame(6);
}


impl GuessGame.start {
    if not [root --> (`?turn)] {
        next = root ++> turn(random.randint(1, 10));
    } else {
        next = [root --> (`?turn)];
    }
    visit next;
}

impl GuessGame.process_guess {
    if [-->] {
        visit [-->];
    } else {
        if self.guess < here.correct_number {
            print('Too high!');
            here ++> turn(here.correct_number);
        } elif self.guess > here.correct_number{
            print('Too low!');
            here ++> turn(here.correct_number);
        } else {
            print('Congratulations! You guessed correctly!.');
            disengage;
        }
    }
}
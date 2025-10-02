'''
    Using AI-Enhanced Gameplay with `byLLM` (Meaning Typed LLM).
    Instead of the simple `Too high`or `Too low` from 
    game5 responses, the game now provides intelligent, context-aware
     hints bt an LLM. This demonstrates how easily AI can be wonev into
     Jac applications to create more engaging user experiences
'''

import random;
import from byllm.llm {Model}

#glob llm = Model(model_name='gpt-4o', verbose=False);
glob llm = Model(model_name='gemini/gemini-2.0-flash', verbose=False);

''' Provide a fun hint if guess is incorrect'''
def give_hint(guess: int, correct_number: int) -> str by llm();

walker GuessGame {
    has guess: int;

    can start with `root entry;
    can process_guess with turn entry;
}

node turn {
    has correct_number: int = random.randint(1, 10);
}

#will run when in CLI mode (not in cloud)
with entry:__main__ {
    root spawn GuessGame(3);
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
            print(give_hint(self.guess, here.correct_number));
            here ++> turn(here.correct_number);
        } elif self.guess > here.correct_number {
            print(give_hint(self.guess, here.correct_number));
            here ++> turn(here.correct_number);
        } else {
            print('Congratulations! You guessed correctly!');
            disengage;
            
        }
    }
}
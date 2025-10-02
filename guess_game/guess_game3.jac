'''Guess game - splits object declarion from their implementation using `impl` 
    The object separation keeps the interface clean and organised in
     larger codespaces
'''
#A number guessing game
import random;

obj Game {
    has attempts: int, won: bool = False;

    def play;

}

obj GuessTheNumberGame (Game) {
    has correct_number: int = random.randint(1, 10);

    def init;
    override def play;
    def process_guess(guess:int);
}

#execute/run the game
with entry{
    game = GuessTheNumberGame();
    game.play();
}

impl Game.play{
    raise NotImplementedError('Subclass must implement this method.');
}

impl GuessTheNumberGame.init{
    self.attempts = 10;
    self.correct_number = random.randint(1, 10);
}

impl GuessTheNumberGame.play{
    while self.attempts > 0 {
        guess = input('Guess a number between 1 and 10: ');
        if guess.isdigit(){
            self.process_guess(int(guess));
        }else {
            print('That is not a valid number! Try again.');
        }
    }
    if not self.won {
        print('Sorry, you did not guess the number. Better luck next time!');
    }
}

impl GuessTheNumberGame.process_guess(guess: int){
    if guess > self.correct_number {
        print('Too high!');
        self.attempts -= 1;
    } elif guess < self.correct_number{
        print('Too low!');
        self.attempts -= 1;

    } else {
        print('Congratulations! You guessed correctly!');
        self.won = True;
        self.attempts = 0;
        return;
    }
    print(f'You have {self.attempts} attempts remaining!');
}

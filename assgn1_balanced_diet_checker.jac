''' Checks a meal combo for 3 nutrients(Proteins, vitamins,carbs)'''
import re;
import from byllm.llm {Model}

#glob llm = Model(model_name='gpt-4o', verbose=False);
glob llm = Model(model_name='gemini/gemini-2.0-flash', verbose=False);

def give_hint(meal: str, balanced_diet: str) -> str by llm();

walker MealChecker {
    has meal: str;

    can start with `root entry;
    can check_meal with turn entry;
}

node turn {
    has balanced_diet: str == 'protein, vitamin, carbs';
}

with entry:__main__ {
    root spawn MealChecker('rice, lentils, cabbage');
    root spawn MealChecker('beans, mashed potatoes');
    root spawn MealChecker('bread, steak, coffee');
}

impl MealChecker.start {
    if not [root --> (`?turn)] {
        next = root ++> turn(str(self.meal));
    } else {
        next = [root --> (`?turn)];
    }
    visit next;
}


impl MealChecker.check_meal {
    if [-->] {
        visit [-->];
    } else {
        if self.meal < here.balanced_diet{
            print(give_hint(self.meal, here.balanced_diet));
            here ++> turn(here.balanced_diet);
        } else {
            print('A well balanced diet! Bon Appetite!!');
            disengage;
            
        }
    }
}
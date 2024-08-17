# sarahs_recipes

A new Flutter project.

## Getting Started

Database structure:

CREATE TABLE recipe (id INT AUTO_INCREMENT, name VARCHAR(100) NOT NULL, image LONGTEXT, category VARCHAR(50) NOT NULL, instructions VARCHAR(10000), PRIMARY KEY(id));

CREATE TABLE ingredient (id INT AUTO_INCREMENT, recipe_id INT NOT NULL, entry_number INT NOT NULL, amount VARCHAR(50), unit VARCHAR(50), name VARCHAR(100) NOT NULL, PRIMARY KEY(id), FOREIGN KEY (recipe_id) REFERENCES recipe(id)); 

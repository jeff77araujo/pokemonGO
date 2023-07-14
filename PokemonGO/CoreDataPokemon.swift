//
//  CoreDataPokemon.swift
//  PokemonGO
//
//  Created by Mac do JEFF on 07/07/23.
//

import UIKit
import CoreData

class CoreDataPokemon {
    
    var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        return context!
    }()
    
    private func addFullPokemons() {
        self.createPokemon(name: "Mew", pokeImage: "mew", captured: false)
        self.createPokemon(name: "Meowth", pokeImage: "meowth", captured: false)
        self.createPokemon(name: "Pikachu", pokeImage: "pikachu", captured: false)
        self.createPokemon(name: "Squirtle", pokeImage: "squirtle", captured: false)
        self.createPokemon(name: "Charmander", pokeImage: "charmander", captured: false)
        self.createPokemon(name: "Caterpie", pokeImage: "caterpie", captured: false)
        self.createPokemon(name: "Bullbasaur", pokeImage: "bullbasaur", captured: false)
        self.createPokemon(name: "Bellsprout", pokeImage: "bellsprout", captured: false)
        self.createPokemon(name: "Snorlax", pokeImage: "snorlax", captured: false)
        self.createPokemon(name: "Psyduck", pokeImage: "psyduck", captured: false)
        self.createPokemon(name: "Zubat", pokeImage: "zubat", captured: false)
        self.createPokemon(name: "Rattata", pokeImage: "rattata", captured: false)
        
        do { try context.save() } catch {}
    }
    
    private func createPokemon(name: String, pokeImage nameImage: String, captured: Bool) {
        let pokemon = Pokemon(context: context)
        
        pokemon.name = name
        pokemon.nameImage = nameImage
        pokemon.captured = captured
    }
    
    func savePokemon(pokemon: Pokemon) {
        pokemon.captured = true
        do { try context.save() } catch {}
    }
    
    func getPokemonCaptured(captured: Bool) -> [Pokemon] {
        let request = Pokemon.fetchRequest() as NSFetchRequest<Pokemon>
        request.predicate = NSPredicate(format: "captured = %@", NSNumber(value: captured))
        
        do {
            let pokemons = try context.fetch(request) as [Pokemon]
            return pokemons
        } catch {}
        
        return []
    }
    
    func getFullPokemons() -> [Pokemon] {
        do {
            let pokemons = try context.fetch(Pokemon.fetchRequest()) as! [Pokemon]
            if pokemons.count == 0 {
                self.addFullPokemons()
                return self.getFullPokemons()
            }
            return pokemons
            
        } catch {}
        
        return []
    }
}


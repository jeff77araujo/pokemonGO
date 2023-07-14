//
//  PokeDexViewController.swift
//  PokemonGO
//
//  Created by Mac do JEFF on 10/07/23.
//

import UIKit

class PokeDexViewController: UIViewController {
    
    var pokemonsCaptured: [Pokemon] = []
    var pokemonsNotCaptured: [Pokemon] = []
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coreData = CoreDataPokemon()
        self.pokemonsCaptured = coreData.getPokemonCaptured(captured: true)
        self.pokemonsNotCaptured = coreData.getPokemonCaptured(captured: false)
        tableView.reloadData()
    }
    
    @IBAction func backMap(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PokeDexViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Capturados"
        }
        return "Não Capturados"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pokemonsCaptured.count
        }
        return pokemonsNotCaptured.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        var pokemon: Pokemon
        
        if indexPath.section == 0 {
            pokemon = self.pokemonsCaptured[indexPath.row]
        } else {
            pokemon = self.pokemonsNotCaptured[indexPath.row]
        }
        
        cell.textLabel?.text = pokemon.name
        cell.imageView?.image = UIImage(named: pokemon.nameImage ?? "")
        
        return cell
    }
    
}

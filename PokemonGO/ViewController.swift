//
//  ViewController.swift
//  PokemonGO
//
//  Created by Mac do JEFF on 05/07/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    var managerLocation = CLLocationManager()
    var coreDataPokemon = CoreDataPokemon()
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        managerLocation.delegate = self
        managerLocation.requestWhenInUseAuthorization()
        managerLocation.startUpdatingLocation()
        
        showPokemon()
        getPokemons()
    }
    
    @IBAction func centerPlayerButton(_ sender: Any) {
        if let coordinate = managerLocation.location?.coordinate {
            centerAnnotation(coordinate)
        }
    }
    
}

// MARK: - Funções Nativas
extension ViewController {
    
    // MARK: - Colocar as imagens nas anotações
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if annotation is MKUserLocation {
            annotationView.image = UIImage(named: "player")
        } else {
            let poke = (annotation as! PokemonAnnotation).pokemon
            annotationView.image = UIImage(named: poke.nameImage ?? "")
        }
        
        var frame = annotationView.frame
        frame.size.height = 40
        frame.size.width = 40
        annotationView.frame = frame
        
        return annotationView
    }
    
    // MARK: pega a seleção da anotação
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        let pokemon = (annotation as! PokemonAnnotation).pokemon
        guard let coordinate = annotation?.coordinate else { return }
        
        mapView.deselectAnnotation(annotation, animated: true)
        
        if annotation is MKUserLocation {
            centerAnnotation(coordinate)
            return
        }
        
        centerAnnotation(coordinate)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            if self.insideTheAreaToCapturePokemon() {
                self.coreDataPokemon.savePokemon(pokemon: pokemon)
                if let annotPoke = annotation {
                    self.map.removeAnnotation(annotPoke)
                    
                    self.alertLocation(title: "Parabéns!",
                                       message: "Você capturou o pokémon: \(pokemon.name ?? "")",
                                       style: .alert,
                                       titleButton: "OK",
                                       handler: false)
                }
            } else {
                self.alertLocation(title: "Sem sucesso:",
                                   message: "Você está muito longe do pokémon: \(pokemon.name ?? "")",
                                   style: .alert,
                                   titleButton: "Tentar outro pokémon",
                                   handler: false)
            }
        }
        
    }
    
    // MARK: - Pega a posição do USER de tempos em tempos e chama a func para centraliza na tela
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = managerLocation.location?.coordinate {
            centerAnnotation(coordinate)
            managerLocation.stopUpdatingLocation()
        }
    }
    
    // MARK: Pedir autorização de localização
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse && status != .notDetermined{
            alertLocation(title: "Permissão de localização",
                          message: "Para que você possa caçar pokemons, precisamos da sua localização",
                          style: .alert,
                          titleButton: "Abrir Configurações",
                          handler: true)
        }
    }
}

// MARK: - Minhas Funções
extension ViewController {
    
    // MARK: Pegar os pokemons do CoreData
    private func getPokemons() {
        self.pokemons = self.coreDataPokemon.getFullPokemons()
    }
    
    // MARK: Validação para verificar se User esta dentro da área da tela
    private func insideTheAreaToCapturePokemon() -> Bool {
        if let coord = managerLocation.location?.coordinate {
            if map.visibleMapRect.contains(MKMapPoint(coord)) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Centralizar anotaçAo
    private func centerAnnotation(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(region, animated: true)
    }
    
    // MARK: - Exibir os pokemons
    private func showPokemon() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            
            if let coordinate = self.managerLocation.location?.coordinate {
                
                let totalPokemons = UInt32(self.pokemons.count)
                let randomPokemonIndex = arc4random_uniform(totalPokemons)
                
                let pokemon = self.pokemons[ Int(randomPokemonIndex) ]
                
                let annotation = PokemonAnnotation(coordinate: coordinate, pokemon: pokemon)
                
                let latiRandom = (Double(arc4random_uniform(500)) - 250) / 100000.0
                let longRandom = (Double(arc4random_uniform(500)) - 250) / 100000.0
                
                annotation.coordinate.latitude += latiRandom
                annotation.coordinate.longitude += longRandom
                
                if annotation.coordinate.latitude != latiRandom || annotation.coordinate.longitude != longRandom {
                    self.map.addAnnotation(annotation)
                }
                
            }
        }
    }
    
    // MARK: - alerta para pedir permissão de localização
    private func alertLocation(title: String,
                               message: String,
                               style: UIAlertController.Style,
                               titleButton: String,
                               handler: Bool) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        
        let actionButton = UIAlertAction(title: titleButton, style: .default) { alert in
            if handler {
                if let config = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(config as URL)
                }
            }
        }
        
        alert.addAction(actionButton)
        
        if handler {
            let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel)
            alert.addAction(actionCancel)
        }
        
        present(alert, animated: true)
        
    }
}

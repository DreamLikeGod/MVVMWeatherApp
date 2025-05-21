//
//  MainViewController.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Search city"
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.returnKeyType = .search
        searchController.automaticallyShowsCancelButton = false
        return searchController
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let viewModel: iMainViewModel
    private var cancellables = Set<AnyCancellable>()
    private var forecast: [ForecastItem] = []
    
    init(viewModel: iMainViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.bindRelations()
        self.viewModel.getWeather(in: "Moscow")
    }
    
    func bindRelations() {
        self.viewModel.getSubject().sink(receiveCompletion: { [weak self] error in
            print(error)
            self?.forecast = []
            
        }, receiveValue: { [weak self] value in
            self?.forecast = value.forecast.forecast
            DispatchQueue.main.async {
                self?.navigationItem.title = "\(value.location.name)/\(value.location.country)"
                self?.tableView.reloadData()
            }
        }).store(in: &cancellables)
    }
}

private extension MainViewController {
    
    func setupView() {
        navigationItem.searchController = self.searchController
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.forecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reuseIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        cell.configureCell(with: forecast[indexPath.item])
        return cell
    }
    
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              !text.isEmpty else {
            self.viewModel.getWeather(in: "Moscow")
            return
        }
        self.viewModel.getWeather(in: text)
    }
}

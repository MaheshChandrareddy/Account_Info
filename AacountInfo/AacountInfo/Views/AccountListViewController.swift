//
//  AccountListViewController.swift
//  IdentityVault
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import UIKit
import CoreData
import PDFKit
import Alamofire

class AccountListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = AccountListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accounts"
        setupTableView()
        fetchData()
    }
    
    @IBAction func downloadAndOpenPDF(_ sender: UIButton) {
        viewModel.fetchPDF { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fileURL):
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let pdfVC = storyboard.instantiateViewController(withIdentifier: "PDFViewerViewController") as? PDFViewerViewController {
                        pdfVC.pdfURL = fileURL
                        self.present(pdfVC, animated: true)
                    }
                case .failure(let error):
                    print("Download failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func navigateToImageHandlerVC(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ImagePresentViewController") as? ImagePresentViewController else {return}
        present(vc, animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "AccountCell", bundle: .main), forCellReuseIdentifier: "AccountCell")
    }
    
    private func fetchData() {
        viewModel.getAccounts {
            self.tableView.reloadData()
        }
    }
    
    private func presentEditAlert(for index: Int) {
        guard let account = viewModel.account(at: index) else { return }
        
        let alert = UIAlertController(title: "Edit Account Name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = account.ActName
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let newName = alert.textFields?.first?.text ?? ""
            let id = self.viewModel.account(at: index)?.actid
            self.viewModel.updateAccountName(for: id ?? 0 , newName: newName){
                self.fetchData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AccountListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = viewModel.account(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.accountNameLabel.text = "Account Name: \(account?.ActName ?? "")"
        cell.accountIdLabel.text = "Account Id: \(account?.actid ?? 0)"
        print(account?.alternateName ?? "na")
        cell.alternateAccountNameLabel.text = "Alternate Name: \(account?.alternateName ?? "-")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.viewModel.deleteAccount(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.presentEditAlert(for: indexPath.row)
            completionHandler(true)
        }
        
        let voiceAction = UIContextualAction(style: .normal, title: "Voice") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let account = self.viewModel.accounts[indexPath.row]
            let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "VoiceInputViewController") as! VoiceInputViewController
            //            vc.accountName = account.ActName ?? "Account"
            vc.accountID = account.actid ?? 0
            vc.delegate = self
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .automatic
            self.present(nav, animated: true)
            completion(true)
        }
        
        voiceAction.backgroundColor = .systemIndigo
        voiceAction.image = UIImage(systemName: "mic.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, voiceAction])
    }
    
}


extension AccountListViewController: VoiceInputDelegate {
    func didFinishVoiceInput(forId: Int, with alternateName: String) {
        viewModel.updateAlternateName(forid: forId, alternateName: alternateName){
            self.fetchData()
        }
    }
}

//
//  PostListViewController.swift
//  ReignDesignApp
//
//  Created by Israel on 03/09/17.
//  Copyright © 2017 IsraelGutierrez. All rights reserved.
//

import UIKit
import CoreData

class PostListViewController: UITableViewController {
    
    var searchController: UISearchController! = nil
    var leftButtonItemView: UIBarButtonItem! = nil
    
    //
    private var arrayOfElements: Array<PostCD>! = Array<PostCD>()
    private var filteredElements: Array<PostCD>! = Array<PostCD>()
    private var companyView: UIImageView! = nil
    weak private var timer: Timer! = nil
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override init(style: UITableViewStyle) {
        
        super.init(style: style)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initInterface()
        
    }
    
    private func initInterface() {
        
        self.title = "IT Posts"
        
        self.getInfoFromServer()
        self.editNavigationController()
        self.initTableView()
        self.initSearchController()
        
    }
    
    private func editNavigationController() {
        
//        self.changeBackButtonItem()
        self.changeNavigationBarTitle()
        
    }
    
    private func changeBackButtonItem() {
        
        let leftButton = UIBarButtonItem(title: "",
                                         style: UIBarButtonItemStyle.plain,
                                         target: nil,
                                         action: nil)
        
        self.navigationItem.leftBarButtonItem = leftButton
        
    }
    
    private func changeNavigationBarTitle() {
        
        let titleLabel = UILabel.init(frame: CGRect.zero)
        
        let font = UIFont.init(name: "AppleSDGothicNeo-Light",
                               size: 18.0 * UtilityManager.sharedInstance.conversionWidth)
        let color = UIColor.black
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let stringWithFormat = NSMutableAttributedString(
            string: "IT Posts",
            attributes:[NSFontAttributeName:font!,
                        NSParagraphStyleAttributeName:style,
                        NSForegroundColorAttributeName:color
            ]
        )
        titleLabel.attributedText = stringWithFormat
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
    }
    
    private func initTableView() {
        
        self.tableView.register(PostListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.backgroundColor = UIColor.gray
        self.refreshControl?.addTarget(self, action: #selector(getInfoFromServer), for: .valueChanged)
        
    }
    
    private func initSearchController() {
        
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.definesPresentationContext = true
        searchController.searchBar.barTintColor = UtilityManager.sharedInstance.backgroundColorForSearchBar
        
        self.tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredElements = arrayOfElements.filter { element in
            
            return element.title!.lowercased().contains(searchText.lowercased()) || element.title!.lowercased().contains(searchText.lowercased())
            
        }
        
        self.tableView.reloadData()
        
    }
    
    @objc private func getInfoFromServer() {
        
        UtilityManager.sharedInstance.showLoader()
        
        ServerManager.sharedInstance.getAllPosts(actionsToDoWhenSucceeded: { (postsFromServer) in
            
            let acceptedPosts = self.getAllAcceptedPosts(postsFromServer: postsFromServer)
            _ = self.deleteAllPostsInCoreData()
            self.insertPosts(arrayofPostsToSaveInCoreData: acceptedPosts)
            
            self.arrayOfElements.removeAll()
            self.filteredElements.removeAll()
            
            self.arrayOfElements = self.getAllPostsFromCoreData()
            self.filteredElements = self.getAllPostsFromCoreData()
            
            self.tableView.reloadData()
            
            self.refreshControl?.endRefreshing()
            
            UtilityManager.sharedInstance.hideLoader()
            
        }, actionsToDoWhenFailed: {
        
            UtilityManager.sharedInstance.hideLoader()
            
            let alertController = UIAlertController(title: "ERROR",
                                                    message: "Connection error. We'll show the info saved in the device",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
                let arrayOfPostsFromCoreData = self.getAllPostsFromCoreData()
            
                self.searchController.isActive = false
                self.refreshControl?.endRefreshing()
            
                self.arrayOfElements = arrayOfPostsFromCoreData
                self.filteredElements = arrayOfPostsFromCoreData
            
                self.tableView.reloadData()
            
            }
            
            alertController.addAction(cancelAction)
                        
            let actualController = UtilityManager.sharedInstance.currentViewController()
            actualController.present(alertController, animated: true, completion: nil)
        
        })
        
    }
    
    private func insertPosts(arrayofPostsToSaveInCoreData: Array<Post>) {
        
        if #available(iOS 10.0, *) {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            for post in arrayofPostsToSaveInCoreData {
                
                let newPost = NSEntityDescription.insertNewObject(forEntityName: "PostCD", into: context)
                newPost.setValue(post.id, forKey: "id")
                newPost.setValue(post.title, forKey: "title")
                newPost.setValue(post.date, forKey: "creationDate")
                newPost.setValue(post.url, forKey: "url")
                
                do {
                    
                    try context.save()
                    
                } catch {
                    
                    print("error creating post")
                    
                    
                }
                
            }
            
        } else {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            
            for post in arrayofPostsToSaveInCoreData {
                
                let newPost = NSEntityDescription.insertNewObject(forEntityName: "PostCD", into: context) as! PostCD
                newPost.id = post.id
                newPost.title = post.title
                newPost.creationDate = post.date! as NSDate!
                newPost.url = post.url
                
            }
            do {
                
                try context.save()
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
        }
        

        
    }
    
    private func insertDeletedPost(deletedPostId: String) {
        
        if #available(iOS 10.0, *) {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let newDeletedPost = NSEntityDescription.insertNewObject(forEntityName: "DeletedPostCD", into: context)
            newDeletedPost.setValue(deletedPostId, forKey: "id")
            
            do {
                
                try context.save()
                
            } catch {
                
                print("error creating deleted post")
                
                
            }
            
        } else {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            let newDeletedPost = NSEntityDescription.insertNewObject(forEntityName: "DeletedPostCD", into: context) as! DeletedPostCD
            newDeletedPost.id = deletedPostId
            
            do {
                
                try context.save()
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            
        }



    }

    private func deleteAllPostsInCoreData() -> Bool {
    
        if #available(iOS 10.0, *) {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PostCD")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                
                try context.execute(deleteRequest)
                try context.save()
                
                return true
                
            } catch {
                
                print ("Error deleting elements")
                
                return false
                
            }
            
        } else {
            
            
            let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            let request: NSFetchRequest<PostCD> = NSFetchRequest<PostCD>.init(entityName: "PostCD")
            //            request.returnsObjectsAsFaults = false
            
            
            var arrayOfPosts = Array<PostCD>()
            
            do {
                
                arrayOfPosts = try context.fetch(request) 
                
                for post in arrayOfPosts {
                    
                    context.delete(post)
                    
                }
                
                try context.save()
                
                return true
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            
            return false
            
        }

    }
    
    private func getAllPostsFromCoreData() -> Array<PostCD> {
        
        if #available(iOS 10.0, *) {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PostCD")
            fetch.returnsObjectsAsFaults = false
            
            var arrayOfPostCD = Array<PostCD>()
            
            do {
                
                arrayOfPostCD = try context.fetch(fetch) as! Array<PostCD>
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            return arrayOfPostCD.sorted{ $0.creationDate!.compare($1.creationDate! as Date) == ComparisonResult.orderedAscending }
            
        } else {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            let request: NSFetchRequest<PostCD> = NSFetchRequest<PostCD>.init(entityName: "PostCD")
//            request.returnsObjectsAsFaults = false
            
            
           var arrayOfPosts = Array<PostCD>()
            
            do {
                
                arrayOfPosts = try context.fetch(request)
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            return arrayOfPosts
            
        }
        

        
    }

    private func getAllDeletedPosts() -> Array<DeletedPostCD> {
    
        if #available(iOS 10.0, *) {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DeletedPostCD")
            fetch.returnsObjectsAsFaults = false
            
            var arrayOfDeletedPostCD = Array<DeletedPostCD>()
            
            do {
                
                arrayOfDeletedPostCD = try context.fetch(fetch) as! Array<DeletedPostCD>
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            return arrayOfDeletedPostCD
            
        } else {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            
            let request: NSFetchRequest<DeletedPostCD> = NSFetchRequest<DeletedPostCD>.init(entityName: "DeletedPostCD")
            //            request.returnsObjectsAsFaults = false
            
            
            var arrayOfDeletedPosts = Array<DeletedPostCD>()
            
            do {
                
                arrayOfDeletedPosts = try context.fetch(request)
                
            } catch {
                
                let alertController = UIAlertController(title: "ERROR",
                                                        message: "Error from internal data base, close and reopen the app",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    
                    
                }
                
                alertController.addAction(cancelAction)
                
                let actualController = UtilityManager.sharedInstance.currentViewController()
                actualController.present(alertController, animated: true, completion: nil)
                
            }
            
            return arrayOfDeletedPosts
            
        }

    
    }

    private func getAllAcceptedPosts(postsFromServer: Array<Post>) -> Array<Post> {
    
        let deletedPosts = self.getAllDeletedPosts()
        var filteredAcceptedPosts: Array<Post> = Array<Post>()
        
        if deletedPosts.count > 0 {
            
            for postFromServer in postsFromServer {
                
                for i in 0..<deletedPosts.count {
                    
                    if postFromServer.id == deletedPosts[i].id! {
                        
                        break
                        
                    } else {
                        
                        if i == deletedPosts.count - 1 {
                            
                            filteredAcceptedPosts.append(postFromServer)
                            
                            break
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } else {
            
            return postsFromServer
            
        }
        
        return filteredAcceptedPosts
    
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { (coordinator) in
            
            if UIDevice.current.orientation.isLandscape {
                
                print("Landscape")
                UtilityManager.sharedInstance.deviceRotated()
                self.initInterface()
                
            } else {
                
                print("Portrait")
                UtilityManager.sharedInstance.deviceRotated()
                self.initInterface()
                
            }
            
        }
        
    }
    
    //MARK - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            if self.searchController.isActive && self.searchController.searchBar.text != "" {
                
                self.insertDeletedPost(deletedPostId: self.filteredElements[indexPath.row].id!)
                self.filteredElements.remove(at: indexPath.row)
                self.tableView.reloadData()
                
            } else {
                
                self.insertDeletedPost(deletedPostId: self.arrayOfElements[indexPath.row].id!)
                self.arrayOfElements.remove(at: indexPath.row)
                self.tableView.reloadData()
                
            }
            
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredElements.count
            
        }
        
        return arrayOfElements.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostListTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            cell.setData(newData: filteredElements[indexPath.row])
            
        } else {
            
            cell.setData(newData: arrayOfElements[indexPath.row])
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 110.0 * UtilityManager.sharedInstance.conversionHeight
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var postData: PostCD
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            postData = filteredElements[indexPath.row]
            
        } else {
            
            postData = arrayOfElements[indexPath.row]
            
        }
        
        let pagePostVC = ShowingWebViewViewController.init(newPost: postData)
        self.navigationController?.pushViewController(pagePostVC, animated: true)
        
    }
    
}

extension PostListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
    
}


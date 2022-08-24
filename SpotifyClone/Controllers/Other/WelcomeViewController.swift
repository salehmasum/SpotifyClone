//
//  WelcomeViewController.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 9/7/2022.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Sign In With Spotify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album_artwork")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Music of your choice \nWhere ever & Whenever \nEnjoy !!"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        view.addSubview(overlayView)
        //title = "Spotify"
        view.backgroundColor = .white
        
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        view.addSubview(label)
        view.addSubview(logoImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        overlayView.frame = view.bounds
        
        signInButton.frame = CGRect(x: 20,
                                    y: view.height - 50 - view.safeAreaInsets.bottom,
                                    width: view.width - 40,
                                    height: 50)
        
        logoImageView.frame = CGRect(x: (view.width - 120)/2, y:(view.height - 350)/2 , width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom + 30, width: view.width - 60, height: 150)
        
    }
    
    @objc func didTapSignIn() {
        let vc = AuthViewController()
        
        vc.completionHandler = {[weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        //Log user in or handle error
        guard success else {
            let alert = UIAlertController(title: "Oops",
                                    message: "Somethig went wrong When Signing",
                                    preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let mainTabBarVc = MainTabBarController()
        mainTabBarVc.modalPresentationStyle = .fullScreen
        present(mainTabBarVc, animated: true)
    }

}

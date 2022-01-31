//
//  WelcomeViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 23.01.22.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var holderView: UIView!
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }
    
    private func configure() {
        scrollView.frame =  holderView.bounds
        holderView.addSubview(scrollView)
        let titles = ["Welcome", "Login With Facebook", "Go check News"]
        
        for x in 0..<3 {
            let pageView = UIView( frame: CGRect(x: CGFloat(x) *  (holderView.frame.size.width), y: 0, width: holderView.frame.size.width, height:  holderView.frame.size.width))
            scrollView.addSubview(pageView)
            
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 20, height: 120))
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10 + 120 + 10, width: pageView.frame.size.width - 20, height: pageView.frame.size.height - 60 - 130 - 15))
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height-60 , width: pageView.frame.size.width - 20, height: 50))
            
            
            label.textAlignment = .center
            
            label.font = UIFont(name: "Helvetica - Bold", size: 32)
            pageView.addSubview(label)
            label.text = titles[x]
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named:"welcome \(x + 1)")
            pageView.addSubview(imageView)
            
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemGray
            button.layer.cornerRadius = 12
            button.setTitle("Continue", for: .normal)
            if x == 2  {
                button.setTitle("get Started", for: .normal)
                
            }
            
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = x+1
            pageView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: holderView.frame.size.width*3, height: 0)
        scrollView.isPagingEnabled = true
        
    }
    
    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 3 else {
            Core.shared.setIsNotNewUse()
            dismiss(animated: true, completion: nil)
            return
        }
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat (button.tag), y: 0), animated: true)
    }
    
}

import UIKit
import MDHTMLLabel
import SafariServices

class InfoViewController: UIViewController {
  
  var viewDidAppearRanOnce = false
  
  var scrollView: UIScrollView?
  let pageMargin: CGFloat = 20
  var contentHeight: CGFloat = 0
  
  let socialMediaIconImagesAndUrls: [(UIImage?, String, String)] = [
    (UIImage(named: "social_media_facebook_icon"),
     "https://www.facebook.com/tcpride/",
     "fb://profile/91251318916"),
    (UIImage(named: "social_media_instagram_icon"),
     "https://www.instagram.com/twincitiespride/",
     "instagram://user?username=twincitiespride"),
    (UIImage(named: "social_media_tumblr_icon"),
     "http://tcpride.tumblr.com",
     "tumblr://x-callback-url/blog?blogName=tcpride"),
    (UIImage(named: "social_media_twitter_icon"),
     "https://twitter.com/TwinCitiesPride",
     "twitter://user?screen_name=tcpride"),
    (UIImage(named: "social_media_youtube_icon"),
     "https://www.youtube.com/user/TwinCitiesPride",
     "youtube://www.youtube.com/user/TwinCitiesPride")
  ]

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if viewDidAppearRanOnce { return }
    
    viewDidAppearRanOnce = true
    
    setUpScrollView()
    
    contentHeight += pageMargin
    setUpConnectWithUsLabel()
    contentHeight += pageMargin
    setUpSocialMediaIcons()
    contentHeight += pageMargin
    setUpInfoLabel()
    contentHeight += pageMargin
    
    scrollView?.contentSize = CGSize(width: view.frame.width,
                                     height: contentHeight)
  }
  
  private func setUpScrollView() {
    let scrollView = UIScrollView(frame: CGRect(x: view.frame.origin.x,
                                                y: view.frame.origin.y,
                                                width: view.frame.width,
                                                height: view.frame.height))
    scrollView.backgroundColor = UIColor.white
    
    view.addSubview(scrollView)
    self.scrollView = scrollView
  }
  
  private func setUpConnectWithUsLabel() {
    let connectWithUsLabel = MDHTMLLabel(frame: CGRect(x: pageMargin,
                                                       y: contentHeight,
                                                       width: view.frame.width
                                                        - 2 * pageMargin,
                                                       height: 0))
    connectWithUsLabel.htmlText = "<font size=\"34\" color=\"#7f3f97\">"
      + "<b>Connect with us</b></font>"
    setProperties(label: connectWithUsLabel)
    scrollView?.addSubview(connectWithUsLabel)
    contentHeight += connectWithUsLabel.frame.height
    print(contentHeight)
  }
  
  private func setUpSocialMediaIcons() {
    let numberOfIcons = CGFloat(socialMediaIconImagesAndUrls.count)
    let iconSpacing: CGFloat = 15
    
    let iconSingleDimension = (view.frame.width - pageMargin * 2
                                - iconSpacing * (numberOfIcons - 1))
                              / numberOfIcons
    
    for (index, tuple) in socialMediaIconImagesAndUrls.enumerated() {
      let (iconImage, _, _) = tuple
      
      let frame = CGRect(x: pageMargin
                            + CGFloat(index) * (iconSpacing
                            + iconSingleDimension),
                         y: contentHeight,
                         width: iconSingleDimension,
                         height: iconSingleDimension)
      
      let iconImageView = UIImageView(image: iconImage)
      iconImageView.frame = frame
      
      let iconButton = UIButton(frame: frame)
      iconButton.tag = index
      iconButton.addTarget(self,
                           action: #selector(InfoViewController
                            .didPressIconButton(sender:)),
                           for: .touchUpInside)
      scrollView?.addSubview(iconImageView)
      scrollView?.addSubview(iconButton)
    }
    
     contentHeight += iconSingleDimension
  }
  
  private func setUpInfoLabel() {
    let infoLabel = MDHTMLLabel(frame: CGRect(x: pageMargin,
                                              y: contentHeight,
                                              width: view.frame.width
                                                - 2 * pageMargin,
                                              height: 0))
    infoLabel.htmlText = ParseManager.shared.infoText
    setProperties(label: infoLabel)
    
    scrollView?.addSubview(infoLabel)
    
    contentHeight += infoLabel.frame.height
  }
  
  func setProperties(label: MDHTMLLabel) {
    label.delegate = self
    label.numberOfLines = 0
    label.font = label.font.withSize(22)
    label.textColor = UIColor.darkGray
    label.sizeToFit()
  }
  
  @objc func didPressIconButton(sender: AnyObject) {
    guard let index = sender.tag else { return }
    guard index <= socialMediaIconImagesAndUrls.count - 1 else { return }
    let (_, webUrlString, appUrlString) = socialMediaIconImagesAndUrls[index]
    guard let webUrl = URL(string: webUrlString) else { return }
    guard let appUrl = URL(string: appUrlString) else { return }

    UIApplication.shared.open(appUrl, options: [:]) {
      success in
      if !success {
        self.open(url: webUrl)
      }
    }
  }
  
  func open(url: URL) {
    let svc = SFSafariViewController(url: url)
    present(svc, animated: true, completion: nil)
  }

}

extension InfoViewController: MDHTMLLabelDelegate {

  func htmlLabel(_ label: MDHTMLLabel!,
                 didSelectLinkWith URL: Foundation.URL!) {
    open(url: URL)
  }

  func htmlLabel(_ label: MDHTMLLabel!,
                 didHoldLinkWith URL: Foundation.URL!) {
    open(url: URL)
  }

}

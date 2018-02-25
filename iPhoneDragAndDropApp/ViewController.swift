
import UIKit

class ViewController: UIViewController {
    
    let redView = UIView()
    let greenView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blueView = UIView()
        blueView.backgroundColor = .blue
        
        greenView.backgroundColor = .green
        greenView.isUserInteractionEnabled = true
        greenView.addSubview(blueView)
        setConstraintsInSuperView(forView: blueView)
        
        redView.backgroundColor = .red
        redView.isUserInteractionEnabled = true
        
        let greenViewDropInteraction = UIDropInteraction(delegate: self)
        let greenViewDragInteraction = UIDragInteraction(delegate: self)
        greenViewDragInteraction.isEnabled = true
        redView.addInteraction(greenViewDragInteraction)
        greenView.addInteraction(greenViewDropInteraction)
        
        let redViewDropInteraction = UIDropInteraction(delegate: self)
        let redViewDragInteraction = UIDragInteraction(delegate: self)
        redViewDragInteraction.isEnabled = true
        greenView.addInteraction(redViewDragInteraction)
        redView.addInteraction(redViewDropInteraction)
        
        let stackView = UIStackView(arrangedSubviews: [greenView, redView])
        view.addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.frame = view.bounds
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
}

extension ViewController {

    // MARK: - Helper methods
    
    func setConstraintsInSuperView(forView subView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subView]-|", options: [], metrics: nil, views: ["subView": subView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subView]-|", options: [], metrics: nil, views: ["subView": subView]))
    }
    
}

extension ViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let containedView = interaction.view?.subviews.first else { return [] }
        let viewContainer = ViewContainer(view: containedView)
        let itemProvider = NSItemProvider(object: viewContainer)
        let item = UIDragItem(itemProvider: itemProvider)
        item.localObject = viewContainer.view
        return [item]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        guard let containedView = interaction.view?.subviews.first else { return }
        containedView.removeFromSuperview()
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        guard let containedView = interaction.view?.subviews.first else { return nil }
        return UITargetedDragPreview(view: containedView)
        
        /*
         guard let containerView = interaction.view, let containedView = containerView.subviews.first else { return nil }
         let center = CGPoint(x: containedView.frame.midX, y: containedView.frame.midY)
         let target = UIDragPreviewTarget(container: containerView, center: center)
         return UITargetedDragPreview(view: containedView, parameters: UIDragPreviewParameters(), target: target)
         */
    }
    
    /*
     func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
         guard case .cancel = operation else { return }
         guard let containedView = session.items.first?.localObject as? UIView else { return }
         interaction.view!.addSubview(containedView)
         self.setConstraintsInSuperView(forView: containedView)
     }
     */

    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        animator.addCompletion { _ in
            guard let containedView = item.localObject as? UIView else { return }
            interaction.view!.addSubview(containedView)
            self.setConstraintsInSuperView(forView: containedView)
        }
    }

    
    func dragInteraction(_ interaction: UIDragInteraction, prefersFullSizePreviewsFor session: UIDragSession) -> Bool {
        return true
    }
    
}

extension ViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: ViewContainer.self) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: view)
        let operation: UIDropOperation
        if interaction.view!.frame.contains(dropLocation) && session.localDragSession != nil {
            operation = .move
        } else {
            operation = .cancel
        }
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: ViewContainer.self) { viewContainers in
            guard let viewContainers = viewContainers as? [ViewContainer], let viewContainer = viewContainers.first else { return }
            interaction.view!.addSubview(viewContainer.view)
            self.setConstraintsInSuperView(forView: viewContainer.view)
        }
    }
    
}

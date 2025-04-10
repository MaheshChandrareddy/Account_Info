//
//  PDFViewerViewController.swift
//  AacountInfo
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {

        @IBOutlet weak var pdfView: PDFView!  // ← from storyboard

        var pdfURL: URL?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            displayPDF()
        }

        private func displayPDF() {
            guard let url = pdfURL else { return }

            if let document = PDFDocument(url: url) {
                pdfView.autoScales = true
                pdfView.document = document
            } else {
                print("Failed to load PDF")
            }
        }

        @IBAction func downloadPDFTapped(_ sender: UIButton) {
            guard let fileURL = pdfURL else { return }
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(activityVC, animated: true)
        }

}

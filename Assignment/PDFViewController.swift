//
//  PDFViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//


import UIKit
import PDFKit

/**
This class generates and displays PDF invoices based on job details. It creates a PDF document, sets up a PDF view, and renders the invoice content.
 It includes methods for generating the PDF data, formatting invoice details, drawing the services table, and sharing the PDF.
 */
class PDFViewController: UIViewController {
    
    var thisJob: Job!
    
    var pdfInvoice: PDFDocument?
    
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.string(forKey: "business name") != ""{
            // Generate PDF
            let pdfData = generatePDFData()
            
            // Create PDFView
            let pdfView = PDFView(frame: view.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            pdfView.displayMode = .singlePageContinuous // Fit the PDF to the screen
            pdfView.autoScales = true // Automatically scale the PDF content
            view.addSubview(pdfView)
            

            pdfInvoice = PDFDocument(data: pdfData)
            pdfView.document = pdfInvoice
            
        }
        else{
            let alertController = UIAlertController(title: "Alert", message: "Please set the business details before generating a PDF", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.performSegue(withIdentifier: "addBusinessDetailsSegue", sender: nil)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // This function generates the data that will be used to generate a PDF.

    func generatePDFData() -> Data {
        // Retrieve business name and owner name from user defaults
        let thisBusinessName = userDefaults.string(forKey: "business name")
        let thisOwnerName = userDefaults.string(forKey: "owner name")
        
        // Set PDF metadata
        let pdfMetaData = [
            kCGPDFContextCreator: thisBusinessName!,
            kCGPDFContextAuthor: thisOwnerName!
        ]
        
        // Set PDF renderer format
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Set page rectangle for standard US Letter size
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        // Create PDF renderer
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // Generate PDF data
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Set fonts
            let textFont = UIFont.systemFont(ofSize: 19.0)
            let tableFont = UIFont.boldSystemFont(ofSize: 19.0)
            
            // Draw invoice title
            let title = "Invoice"
            let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36.0)]
            let titleRect = CGRect(x: 20, y: 20, width: pageRect.width - 40, height: 60)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Draw invoice details
            let detailsRect = CGRect(x: 20, y: 80, width: pageRect.width - 40, height: 200)
            let detailsText = formatInvoiceDetails()
            detailsText.draw(in: detailsRect, withAttributes: [NSAttributedString.Key.font: textFont])
            
            // Draw company and owner information aligned to the right
            let rightAlignedRect = CGRect(x: 20, y: 30, width: pageRect.width - 40, height: 60)
            let companyAndOwnerString = "\(pdfMetaData[kCGPDFContextCreator]!) • \(pdfMetaData[kCGPDFContextAuthor]!)"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            let rightAlignedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 19.0), .paragraphStyle: paragraphStyle]
            companyAndOwnerString.draw(in: rightAlignedRect, withAttributes: rightAlignedAttributes)
            
            // Draw services table
            let tableRect = CGRect(x: 20, y: 280, width: pageRect.width - 40, height: 200)
            drawServicesTable(in: tableRect, withFont: tableFont)
        }
        
        return data
    }


    
    // This function formats the invoice details as a string.
    func formatInvoiceDetails() -> String {
        let details = NSMutableAttributedString()
        
        // Retrieve client name from the current job
        let name = thisJob.job_client?.name
        let nameString = "Client Name: \(name!)\n"
        details.append(NSAttributedString(string: nameString))
        
        // Format the drop-off date using a date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let date = formatter.string(from: thisJob.dropoff_date!)
        let dateString = "Date: \(date)\n"
        details.append(NSAttributedString(string: dateString))
        
        return details.string
    }


    
    // This function draws the services table within the specified rectangle using the given font.
    func drawServicesTable(in rect: CGRect, withFont font: UIFont) {
        // Draw table header
        let headers = ["Service Name", "Quantity", "Price"]
        let headerAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let headerRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 30)
        drawTableRow(in: headerRect, withTexts: headers, andAttributes: headerAttributes, backgroundColor: .black)
        
        // Define the services data
        let services = [
            [(thisJob.job_appointmentType?.type)!,"1",(thisJob.quote)!]
        ]
        let rowHeight: CGFloat = 30.0
        let rowAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        var y = rect.minY + 30 // Adjust y position for rows
        
        // Draw each service row
        for service in services {
            let rowRect = CGRect(x: rect.minX, y: y, width: rect.width, height: rowHeight)
            drawTableRow(in: rowRect, withTexts: service, andAttributes: rowAttributes, backgroundColor: .white)
            y += rowHeight
        }
        
        // Draw the total row
        let totalRowRect = CGRect(x: rect.minX, y: y, width: rect.width, height: rowHeight)
        drawTableRow(in: totalRowRect, withTexts: ["Total","",(thisJob.quote)!], andAttributes: rowAttributes, backgroundColor: .lightGray)
    }

    
    // This function draws a single row of a table within the specified rectangle, using the provided texts, attributes, and background color.
    func drawTableRow(in rect: CGRect, withTexts texts: [String], andAttributes attributes: [NSAttributedString.Key: Any], backgroundColor: UIColor) {
        backgroundColor.setFill()
        UIRectFill(rect)
        
        // Iterate over the texts and draw each one in its corresponding column
        for (index, text) in texts.enumerated() {
            let columnWidth = rect.width / CGFloat(texts.count)
            let columnRect = CGRect(x: rect.minX + (CGFloat(index) * columnWidth), y: rect.minY, width: columnWidth, height: rect.height)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let textRect = CGRect(x: columnRect.minX, y: columnRect.minY + 3, width: columnRect.width, height: columnRect.height)
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(in: textRect)
        }
    }

    
    //function to be able to share the PFD
    @IBAction func sharePDF(_ sender: Any) {
        
        let activityViewController = UIActivityViewController(activityItems: [pdfInvoice!.dataRepresentation()!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    
}

# NfcLib-iOS
An easy to use Nfc library for iOS

## Setup

```pod
pod 'NfcLib'
```

### *Add the NFC entitlement to your project*


## Usage 

### A simple usage of the library to read from a tag

```Swift
var readNfc: ReadNfc?

override func viewDidLoad() {
        super.viewDidLoad()
        
        // create readNfc
        readNfc = NfcFactory<ReadNfc>.create(viewController: self)
    
 }
 
 
 func scan() {
  readNfc?.begin() { results in
                // Upon comletion grab the array with the results
                self.handleResults(results: results)
            }
 
 }
 
/**
 Handle the results from NTAG
*/
func handleResults(results: [Any]) {
        for (index, result) in results.enumerated() {
            switch result {
            case is String:
                // Display String
                self.displayResults(index, result: result as! String)
            case is URL:
                // Display URL
                self.displayResults(index, result: result as! URL)
            default:
                // No data :(
                debugPrint("No data :(")
            }
        }
}
    
func displayResults(_ index: Int, result: String) {
     var prevText = resultsTextView.text!
     prevText += "\(index+1). \(result)\n"
     resultsTextView.text = prevText
}
    
func displayResults(_ index: Int, result: URL) {
    var prevText = resultsTextView.text!
    prevText += "\(index+1). \(result.absoluteString)\n"
    resultsTextView.text = prevText
}

```

### A simple usage of the library to write to a tag

```Swift
var writeNfc: WriteNfc?

override func viewDidLoad() {
        super.viewDidLoad()
        // create writeNfc
        writeNfc = NfcFactory<WriteNfc>.create(viewController: self)
    
}
    
func scan() {
  writeNfc?.begin(message: "Hellom from NFCLib") { result in
         // result is boolean
         if result {
             self.displayResults(0, result: "Writen to tag successfully")
         } else {
              self.displayResults(-1, result: "Error writing to tag!")
         }
  }

}
    
```

### A simple usage of the library to read and write to a tag

*Don't do a read after a write operation, remove the NTAG and use the scan session again*

```Swift
var readNfc: ReadNfc?
var writeNfc: WriteNfc?
var readFlag = true

override func viewDidLoad() {
        super.viewDidLoad()
        
        // create readNfc
        readNfc = NfcFactory<ReadNfc>.create(viewController: self)
        // create writeNfc
        writeNfc = NfcFactory<WriteNfc>.create(viewController: self)
    
}

func scan() {
        
        // READ
        if readFlag {
            readNfc?.begin() { results in
                // Upon comletion grab the array with the results
                self.handleResults(results: results)
            }
        
            // End the connection after 2 sec and display the alert for 1 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Delay dismissing the alert after showing the message
                self.readNfc?.end(message: "Testing end() function", delay: 1)
            }
            
        } else { // WRITE
            writeNfc?.begin("") { result in
                if result {
                    self.displayResults(0, result: "Writen to tag successfully")
                } else {
                    self.displayResults(-1, result: "Error writing to tag!")
                }
            }
        }
}

```

## License
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

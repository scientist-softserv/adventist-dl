Flipflop.configure do
  feature :show_featured_researcher,
          default: false,
          description: "Shows the Featured Researcher tab on the homepage."

  feature :show_share_button,
          default: true,
          description: "Shows the 'Share Your Work' button on the homepage."

  # Flipflop.default_pdf_viewer? returning `true` means we use PDF.js and `false` means we use IIIF Print.
  feature :default_pdf_viewer,
          default: true,
          description: "Choose PDF.js or Universal Viewer to render PDFs. UV uses IIIF Print and requires PDF spltting with OCR. Switching from PDF.js to the UV may require re-ingesting of the PDF."
 end

#!/usr/bin/env ruby

require 'prawn'
require 'json'


def do_swatch(pdf, swatch, row, col, row_height, col_width)
  x = (col * col_width)
  y = (row * row_height)
  top = (y + row_height)
  valid_swatch = !swatch.nil? and !swatch.empty?
  brand = valid_swatch ? swatch[:brand] : ""
  name = valid_swatch ? swatch[:name] : ""
  full_pan = if !valid_swatch
               false
             elsif swatch.include?(:full)
               swatch[:full]
             else
               false
             end
  full_pan= full_pan.nil? ? false : full_pan
  pdf.stroke { pdf.rectangle([x, top], col_width * (full_pan ? 2 : 1), row_height) }
  pdf.font_size(5)
  pdf.text_box(brand, at: [x+2, top-2], height: row_height, width: col_width) unless brand.nil? or brand.empty?
  pdf.text_box(name, at: [x+2, y + 12], height: 15, width: col_width-2) unless name.nil? or name.empty?
  full_pan ? 2 : 1
end


def do_page(filename)
  file = File.read(filename)
  data = JSON.parse(file, symbolize_names: true)
  page = data[:page]
  width = page[:width]
  height = page[:height]
  number_of_rows = page[:rows]
  number_of_cols = page[:cols]
  row_height = height / number_of_rows
  col_width = width / number_of_cols
  swatches = data[:swatches]
  output_file_name = "#{File.basename(filename, '.json')}.pdf"
  Prawn::Document.generate(output_file_name) do |pdf|
    b = pdf.bounds
    puts "Top: #{b.top}"
    puts "Bottom: #{b.bottom}"
    puts "Left: #{b.left}"
    puts "Right: #{b.right}"
    pdf.bounding_box([30, 600], width: width, height: height) do
      for row in 0...number_of_rows
        swatch_row = swatches[row]
        col = 0
        while col < number_of_cols
          swatch = swatch_row[col]
          col += do_swatch(pdf, swatch, row, col, row_height, col_width)
        end
      end
    end
  end

end

do_page(ARGV[0])

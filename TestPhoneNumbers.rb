def extract_phone_number(input)
  firstCharIndex = input =~ /[a-zA-Z#]/
  number         = input[0..firstCharIndex-1]
  return clean_phone_number(number)
end

def clean_phone_number(input)
  if input.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
    [$1, $2, $3].join()
  end
end

body = "1 (858)229-5512 Something something dskfdl"
puts extract_phone_number(body)
puts body
puts
body = "18582295512 Something something dskfdl"
puts body
puts extract_phone_number(body)
puts
body = "+18582295512 Something something dskfdl"
puts body
puts extract_phone_number(body)
puts
body = "1(858)229-5512 Something something dskfdl"
puts body
puts extract_phone_number(body)
puts
body = "1(858) 229 5512 Something something dskfdl"
puts body
puts extract_phone_number(body)
puts
body = "#1(858) 229 5512 Something something dskfdl"
puts body
puts extract_phone_number(body).length
puts


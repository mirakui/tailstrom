value = col[2]
key = case col[3]
      when %r(^/photos/)
        'photos'
      when %r(^/users/)
        'users'
      when %r(^/products/)
        'products'
      end
#filter = 'value > 0'

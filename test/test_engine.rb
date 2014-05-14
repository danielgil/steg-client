gem 'test-unit'
require 'test/unit'
require 'steg-client/hash'
require 'steg-client/engine'

class TestEngine < Test::Unit::TestCase

  def setup
  end

  def test_encode
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    message = 'mazinger rocks'
    expected = 'knock014mazinger rocks'

    # Act
    steganogram = engine.encode(message)

    # Assert
    assert_equal expected, steganogram
  end

  def test_decode_valid
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
        :verbose            => true
    }
    engine = Stegclient::Engine.new(options)
    steganogram = 'knock020Goku i$ even cooler!'
    expected = 'Goku i$ even cooler!'

    #Act
    message = engine.decode(steganogram)

    #Assert
    assert_equal expected, message
  end

  def test_decode_invalid_length
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    steganogram = 'knock025Goku i$ even cooler!'

    #Act
    message = engine.decode(steganogram)

    #Assert
    assert_true message.nil?
  end

  def test_decode_missing_knockcode
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    steganogram = '020Goku i$ even cooler!'

    # Act
    message = engine.decode(steganogram)

    # Assert
    assert_true message.nil?
  end

  def test_extract_header
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :outputmethod       => 'Header',
        :outputmethodconfig => 'X-Powered-By',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers = {
        'date'              => 'Thu, 24 Apr 2014 15:08:14 GMT',
        'server'            => 'Apache/2.4.9 (Fedora)',
        'x-powered-by'      => 'PHP/5.4.0knock024Spiddy is not bad thoughYesheis',
        'connection'        => 'close',
    }
    engine = Stegclient::Engine.new(options)
    expected = 'knock024Spiddy is not bad though'

    # Act
    steganogram = engine.extract(headers)

    # Assert
    assert_equal expected, steganogram
  end

  def test_inject_header
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :inputmethod       => 'Header',
        :inputmethodconfig => 'Accept-Encoding',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflate'],
        'proxy-connection'  => ['Keep-Alive'],
    }
    steganogram = 'knock024Spiddy is not bad though'

    expected = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflateknock024Spiddy is not bad though'],
        'proxy-connection'  => ['Keep-Alive'],
    }
    engine = Stegclient::Engine.new(options)

    # Act
    engine.inject(steganogram, headers)

    # Assert
    assert_equal expected, headers
  end

  def test_inject_present
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :inputmethod       => 'Present',
        :inputmethodconfig => 'Accept-Encoding gzip, deflate',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflate'],
        'proxy-connection'  => ['Keep-Alive'],
    }

    header_present = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflate'],
        'proxy-connection'  => ['Keep-Alive'],
    }

    header_absent = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'proxy-connection'  => ['Keep-Alive'],
    }

    steganogram = 'knock016ls -lah 2>/dev &'
    expected = Array.new
    # Transform steganogram into bit array
    steganogram.bytes.each do |number|
      char = Array.new(8) { |i| number[i] }.reverse!
      # Build the expected result. It's an array of hashes, where every element is
      # a 'headers' hash
      char.each do |bit|
        expected.push header_absent if bit.equal?(0)
        expected.push header_present if bit.equal?(1)
      end
    end

    engine = Stegclient::Engine.new(options)

    # Act
    result = Array.new
    (steganogram.length*8).times do
      # Since every char will be converted to 8 bits, we send length*8 requests
      engine.inject(steganogram, headers)
      result.push headers.clone
    end

    # Assert
    assert_equal expected, result
  end

  def test_extract_present
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :outputmethod       => 'Present',
        :outputmethodconfig => 'X-Powered-By',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers_present = {
        'date'              => 'Thu, 24 Apr 2014 15:08:14 GMT',
        'server'            => 'Apache/2.4.9 (Fedora)',
        'x-powered-by'      => 'PHP/5.4.0',
        'connection'        => 'close',
    }
    headers_absent = {
        'date'              => 'Thu, 24 Apr 2014 15:08:14 GMT',
        'server'            => 'Apache/2.4.9 (Fedora)',
        'connection'        => 'close',
    }

    engine = Stegclient::Engine.new(options)
    expected = 'knock011some result'
    input_array = Array.new

    # Convert expected into a binary array, e.g. [0, 1, 1, 0, ...], and add some junk in front and after
    real_input = 'akno2' + expected + 'what'
    real_input.bytes.each do |number|
      char = Array.new(8) { |i| number[i] }.reverse!
      # Build an array with the headers of all the requests that will be sent, headers_absent when 0 and headers_present when 1
      char.each do |bit|
        input_array.push headers_absent if bit.equal?(0)
        input_array.push headers_present if bit.equal?(1)
      end
    end

    # Act
    result = nil
    input_array.each do |headers|
      result = engine.extract(headers)
      # Assert
      assert_equal expected, result unless result.nil?
    end


  end
end
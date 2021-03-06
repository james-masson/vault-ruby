require "spec_helper"

module Vault
  describe Client do

    def free_address
      server = TCPServer.new("localhost", 0)
      address = ["localhost", server.addr[1]]
      server.close
      address
    end

    describe "#request" do
      specify "raises HTTPConnectionError if it takes too long to read packets from the connection" do
        TCPServer.open('localhost', 0) do |server|
          Thread.new do
            client = server.accept
            sleep 3
            client.close
          end

          address = "http://%s:%s" % ["localhost", server.addr[1]]

          client = described_class.new(address: address, token: "foo", read_timeout: 0.01)

          expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)
        end
      end

      specify "raises HTTPConnectionError if the port on the remote server is not open" do
        address = "http://%s:%s" % free_address

        client = described_class.new(address: address, token: "foo")

        expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)
      end
    end
  end
end

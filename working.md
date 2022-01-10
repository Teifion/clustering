https://hexdocs.pm/elixir/Node.html
https://stackoverflow.com/questions/17351882/how-to-connect-two-elixir-nodes-via-local-network
```
Interactive Elixir (1.12.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(clustering@cbox1)1> Node.list()
[]
iex(clustering@cbox1)2> Node.self()
:clustering@cbox1
iex(clustering@cbox1)3> Node.get_cookie()
:"PI2XBTYCAFQNCNWX25CEHVJVY5NHSCRITI5TYUU5FC76IRLZBFXQ===="
iex(clustering@cbox1)4> Node.connect(:clustering@cbox2)
true
iex(clustering@cbox1)5> 
```

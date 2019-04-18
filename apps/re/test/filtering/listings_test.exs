defmodule Re.Filtering.ListingsTest do
  use Re.ModelCase

  alias Re.Filtering

  describe "apply/2" do
    test "create query for min_price" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  price: %{
                    gte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{min_price: 100})
    end

    test "create query for max_price" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  price: %{
                    lte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{max_price: 100})
    end

    test "create query for min_rooms" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  rooms: %{
                    gte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{min_rooms: 100})
    end

    test "create query for max_rooms" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  rooms: %{
                    lte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{max_rooms: 100})
    end

    test "create query for min_area" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  area: %{
                    gte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{min_area: 100})
    end

    test "create query for max_area" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  area: %{
                    lte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{max_area: 100})
    end

    test "create query for min_garage_spots" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  garage_spots: %{
                    gte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{min_garage_spots: 100})
    end

    test "create query for max_garage_spots" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                range: %{
                  garage_spots: %{
                    lte: 100
                  }
                }
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{max_garage_spots: 100})
    end

    test "create query for types" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                terms: %{type: ["Apartamento", "Casa"]}
              }
            ]
          }
        }
      }

      assert query_result == Filtering.Listings.apply(Listing, %{types: ["Apartamento", "Casa"]})
    end

    test "create query for neighborhood slug" do
      query_result = %{
        query: %{
          bool: %{
            filter: [
              %{
                terms: %{neighborhood_slug: ["copacabana", "ipanema"]}
              }
            ]
          }
        }
      }

      assert query_result ==
               Filtering.Listings.apply(Listing, %{neighborhoods_slugs: ["copacabana", "ipanema"]})
    end
  end
end

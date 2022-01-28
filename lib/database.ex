# use Amnesia

# defdatabase Database do
#   deftable(
#     KVPair,
#     [{:id, autoincrement}, :key, :value],
#     type: :ordered_set,
#     index: [:key]
#   )

#   deftable(
#     Account,
#     [{:id, autoincrement}, :first_name, :last_name, :balance],
#     type: :ordered_set,
#     index: [:balance]
#   )
# end

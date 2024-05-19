import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/services/secure_storage.dart';

clearData(BuildContext context) {
  UserSecureStorage().delete(key: 'accessToken').then((_) {
    UserSecureStorage().delete(key: 'accessTokenExpiresAt').then((_) {
      UserSecureStorage().delete(key: 'username').then((_) {
        UserSecureStorage().delete(key: 'password').then((_) {
          context.read<UserInfoCubit>().delete();
          context.read<BusinessBreakfastCubit>().delete();
          context.read<BusinessLunchCubit>().delete();
          context.read<BusinessDinnerCubit>().delete();
          context.read<PendingOrdersBusinessCubit>().delete();
          context.read<RecommendedItemsCubit>().delete();
          context.read<NearbyItemsCubit>().delete();
          context.read<FavouriteItemsCubit>().delete();
          context.read<SearchFiltersCubit>().delete();
        });
      });
    });
  });
}
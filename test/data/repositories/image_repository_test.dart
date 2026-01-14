import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/data/repositories/image_repository.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/image_error_codes.dart';

import '../../../testing/fakes/services/fake_image_service.dart';

void main() {
  late FakeImageService fakeImageService;
  late ImageRepository imageRepository;

  setUp(() {
    fakeImageService = FakeImageService();
    imageRepository = ImageRepository(fakeImageService);
  });

  group(
    'ImageRepository tests',
    () {
      group(
        'pickImages',
        () {
          test('Should return a list of image paths', () async {
            // Arrange
            final currentImages = <String>[];
            fakeImageService.overridePickImagesResult = ['path1', 'path2'];

            // Act
            final result = await imageRepository.pickImages(currentImages);

            // Assert
            expect(result.isRight(), true);
            result.fold(
              (_) => fail('Expected a list of image paths'),
              (paths) {
                expect(paths, ['path1', 'path2']);
              },
            );
          });

          test(
            'Should return current image paths if the user didnt pick anything',
            () async {
              // Arrange
              final currentImages = ['existing_path1', 'existing_path2'];
              fakeImageService.overridePickImagesResult = [];

              // Act
              final result = await imageRepository.pickImages(currentImages);

              // Assert
              expect(result.isRight(), true);
              result.fold(
                (_) => fail('Expected current image paths'),
                (paths) {
                  expect(paths, currentImages);
                },
              );
            },
          );

          test(
            'should not return duplicate images',
            () async {
              // Arrange
              final currentImages = ['existing_path1', 'existing_path2'];
              fakeImageService.overridePickImagesResult = ['existing_path1', 'existing_path2', 'new_path'];

              // Act
              final result = await imageRepository.pickImages(currentImages);

              // Assert
              expect(result.isRight(), true);
              result.fold(
                (_) => fail('Expected a list of image paths without duplicates'),
                (paths) {
                  expect(paths, ['existing_path1', 'existing_path2', 'new_path']);
                },
              );
            },
          );

          test(
            'should return ImageErrorCodes.maxImagesExceeded if max images is exceeded',
            () async {
              // Arrange
              const maxImages = AppConfig.maxImages;
              final currentImages = List.generate(maxImages, (index) => 'existing_path$index');

              // Act
              final result = await imageRepository.pickImages(currentImages);

              // Assert
              expect(result.isLeft(), true);
              result.fold(
                (failure) {
                  expect(failure.code, ImageErrorCodes.maxImagesExceeded);
                },
                (_) => fail('Expected a failure due to max images exceeded'),
              );
            },
          );
        },
      );

      group(
        'takePicture',
        () {
          test('Should return a list of image paths', () async {
            // Arrange
            final currentImages = <String>[];
            fakeImageService.overrideTakePictureResult = 'new_picture_path';

            // Act
            final result = await imageRepository.takePicture(currentImages);

            // Assert
            expect(result.isRight(), true);
            result.fold(
              (_) => fail('Expected a list of image paths'),
              (paths) {
                expect(paths, ['new_picture_path']);
              },
            );
          });

          test(
            'Should return current image paths if the service didnt take a picture',
            () async {
              // Arrange
              final currentImages = ['existing_path1', 'existing_path2'];
              fakeImageService.overrideTakePictureResult = '';

              // Act
              final result = await imageRepository.takePicture(currentImages);

              // Assert
              expect(result.isRight(), true);
              result.fold(
                (_) => fail('Expected current image paths'),
                (paths) {
                  expect(paths, currentImages);
                },
              );
            },
          );

          test(
            'should return ImageErrorCodes.maxImagesExceeded if max images is exceeded',
            () async {
              // Arrange
              const maxImages = AppConfig.maxImages;
              final currentImages = List.generate(maxImages, (index) => 'existing_path$index');

              // Act
              final result = await imageRepository.takePicture(currentImages);

              // Assert
              expect(result.isLeft(), true);
              result.fold(
                (failure) {
                  expect(failure.code, ImageErrorCodes.maxImagesExceeded);
                },
                (_) => fail('Expected a failure due to max images exceeded'),
              );
            },
          );
        },
      );
    },
  );
}
